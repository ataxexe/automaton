# Módulo aplicado a todas as conexões dos autômatos para facilitar as operações que envolvam conexões vazias
#
# Marcelo Guimarães
module Connection

  # Verifica se existe pelo menos uma conexão vazia
  def has_empty?
    self.each do |key, value|
      if value.is_a?(Array)
        value.each do |val|
          return true if val.empty_mov?
        end
      else
        return true if value.empty_mov?
      end
    end
    false
  end
  # Adiciona a conexão do valor ao estado
  def add value, state
    state = {:state => state, :value => value}
    def state.empty_mov?
      self[:value] == ''
    end
    if self[value]
      if self[value].is_a? Array
        self[value] << state
      else
        self[value] = [self[value]] << state
      end
    else
      self[value] = state
    end
  end
  # Retorna as possíveis conexões para o valor informado
  def get value
    result = self[value]
    if self[""]
      empty = self[""].is_a?(Array) ? self[""] : [self[""]]
      if result.nil?
        result = empty
      else
        result = empty + (result.is_a?(Array) ? result : [result])
      end
    end
    result
  end

end
