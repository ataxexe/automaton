# Módulo de integração com a ferramenta JFlap
#
# Marcelo Guimarães
module JFLAP

  def self.included(base)
    base.send(:extend, JFLAP::In)
    base.send(:include, JFLAP::Out)
  end

  module Out
    # Exporta este autômato para o formato xml lido pelo programa JFLAP.
    #
    # Para usar esse recurso, deve ser carregada a biblioteca Builder (require 'builder')
    def to_jflap
      xml = ""
      builder = Builder::XmlMarkup.new(:target => xml, :indent => 2)
      builder.instruct!

      builder.structure do
        builder.automaton do
          builder.type "fa"
          id = 0
          @states.each do |st|
            builder.state(:id => st, :name => "q#{st}") do
              builder.initial if @initial_state == st
              builder.final if @final_states.include? st
            end
            id += 1
          end
          block = lambda do |builder, from, to, value|
            builder.from from
            builder.to to[:state]
            builder.read value
          end
          @connections.each do |from, conn|
            conn.each do |value, to|
              builder.transition do
                if to.is_a?(Array)
                  to.each do |t|
                    block.call builder, from, t, value
                  end
                else
                  block.call builder, from, to, value
                end
              end
            end
          end
        end
      end
      xml
    end
  end

  module In
    # Cria um autômato baseando-se em um xml no formato JFLAP
    #
    # É possível definir variáveis de contexto e simplificar o autômato no JFLAP, abaixo segue um exemplo.
    #
    # Se uma transição puder ser feita com vários valores, basta indicar no JFLAP uma variável começando
    # por '@' e, no código da importação, informar essa variável - sem o '@' - com o valor desejado. Para
    # uma transição cujos valores sejam de 'a' a 'z' e a variável da transição seja @var, o código da
    # importação seria:
    #
    # Automaton::from_jflap(jflap, {:var => 'a'..'z'})
    #
    # jflap -> xml para importação
    # context (opcional) -> hash com as variáveis de contexto para avaliar os valores das transições de estado
    def from_jflap jflap, context = nil
      initial_state = nil
      final_states = []
      transitional_states = []

      xml = REXML::Document.new jflap

      REXML::XPath.each(xml, "//structure/automaton/state") do |el|
        transitional = true
        if el.elements['initial']
          initial_state = el.attributes['id']
          transitional = false
        end
        if el.elements['final']
          final_states << el.attributes['id']
          transitional = false
        end
        if transitional
          transitional_states << el.attributes['id']
        end
      end

      fa = Automaton::new :initial_state => initial_state, :final_states => final_states

      REXML::XPath.each(xml, "//structure/automaton/transition") do |el|
        from_state = el.elements['from'].text
        to_state = el.elements['to'].text
        value = el.elements['read'].text

        # verifica a existência de expressões para avaliação
        value = parse(value, context) if context and value.index /@\w+/
        fa.connect from_state, :to => to_state, :when => value
      end
      fa
    end

    private

    def parse expression, context
      bind = Object::new
      context.each do |key, value|
        bind.instance_variable_set "@#{key}", value
      end
      binds = bind.send(:binding)
      return eval(expression, binds)
    end
  end

end
