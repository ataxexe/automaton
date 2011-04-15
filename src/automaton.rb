require 'set'
require 'rexml/document'
require 'connection'
require 'jflap'

# Classe que representa um autômato finito. Ela oferece suporte a autômatos finitos determinísticos,
# não-determinísticos e com movimento vazio.
#
# Há, ainda, a possibilidade de importar um XML do programa JFLAP (http://www.jflap.org/) e exportar
# um objeto Automaton para esse formato.
#
# Todos os estados são armazenados no autômato no formato de String.
#
# Marcelo Guimarães
class Automaton
    include JFLAP
  # Constrói um autômato
  #   - params -> Hash com os parâmetros de inicialização
  #     - :initial_state => estado inicial
  #     - :final_states => Array ou Range com os estados finais
  #     - :connections (opcional) => hash com as conexões:
  #         estado_inicial => { estado_final => valor, ... }
  #
  # É permitido o uso de Array e Range nos valores do hash de conexões
  def initialize params
    @initial_state = params[:initial_state].to_s
    @final_states = params[:final_states].collect {|st| st.to_s}
    @states = ([@initial_state] + @final_states).to_set
    @connections = {}
    initialize_hash_connections params[:connections]
    check_integrity
  end

  # Conecta um estado a outro baseando-se em um valor pré-definido para a transição.
  #
  # - state -> deve ser o estado inicial da transição.
  # - params -> ser um hash contendo, as seguintes entradas:
  #   - :to => estado final da transição
  #   - :when => valor para que a transição ocorra, também pode ser passado um Range ou Array com os valores.
  #              Caso não seja informado ou seja "", será considerado um movimento vazio.
  def connect state, params
    state = state.to_s
    params = {:when => ""}.merge! params
    connection = @connections[state]
    unless connection
      connection = {}
      connection.extend Connection
      @connections[state] = connection
    end
    value = params[:when]
    dest_state = params[:to].to_s
    @states << dest_state unless @states.include? dest_state
    @states << state unless @states.include? state

    if value.is_a? Array or value.is_a? Range
      value.each do |val|
        connection.add val.to_s, dest_state
      end
    else
      connection.add value.to_s, dest_state
    end
  end

  # Verifica se o valor informado é compatível com este autômato.
  #
  # - value -> Objeto para validação.
  #
  # Será avaliada a representação em String do objeto passado (to_s).
  def accept? value = ""
    value ||= ""
    _accept? value.to_s.split(//)
  end

  # Verifica se o valor informado não é compatível com este autômato.
  def reject? value
    not accept? value
  end

  private

  # Verifica a integridade deste autômato
  def check_integrity
    raise Exception, "Final states not defined." if @final_states.empty?
    raise Exception, "Initial state not defined." if not @initial_state
    self
  end

  # Inicializa as conexões definidas na sintaxe de construtor em formato de Hash
  def initialize_hash_connections connections
    if connections
        connections.each do |from, conn|
        conn.each do |to, value|
          connect from, :to => to, :when => value
        end
      end
    end
  end

  def _accept? values, state = @initial_state, offset = 0
    index = offset
    connections = @connections[state]
    # A iteração deve ocorrer enquanto houver caracteres para avaliar ou estados vazios para transição, visto que
    # eles podem ser usados independente de existir ou não um caracter para avaliação.
    while index < values.size or (connections and connections.has_empty?)
      return false unless connections
      value = values[index]
      connection = connections.get value
      return false unless connection
      if connection.is_a? Array
        accept = false
        connection.each do |conn|
          # Em caso de a conexão ser vazia, não se deve levar em conta o caractere, por isso o índice não é alterado
          accept = _accept? values, conn[:state], index + (conn.empty_mov? ? 0 : 1)
          break if accept
        end
        return accept
      end
      state = connection[:state]
      connections = @connections[state]
      index += 1
    end
    @final_states.include? state
  end
  
end
