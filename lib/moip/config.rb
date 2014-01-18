# encoding: utf-8
module MoIP
  class Config
    # URI para acessar o serviço
    attr_accessor :uri
    @uri = 'https://www.moip.com.br'

    # Token de autenticação
    attr_accessor :token

    # Chave de acesso ao serviço
    attr_accessor :key
  end
end
