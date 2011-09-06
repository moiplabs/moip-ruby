# MoIP

Esta Gem permite utilizar a API do MoIP, gateway de pagamentos do IG.

## Pagamento direto

O Pagamento Direto é um recurso que a MoIP disponibiliza para aqueles clientes que necessitam de uma flexibilidade maior do que a Integração HTML pode oferecer.

Diferentemente de como é feito com a Integração HTML, seu cliente não precisa ser redirecionado para o site da MoIP para concluir a compra: tudo é feito dentro do ambiente do seu site, dando ao cliente uma maior segurança e confiança no processo.

As formas de pagamento disponibilizadas pela Gem são:

* Boleto
* Débito
* Cartão de Crédito

## Instalação

Instale a Gem
    gem install moip

Adicione a Gem ao Gemfile
    gem "moip"

## Utilização

O MoIP possui uma SandBox de testes que permite a simulação de pagamentos. Para utilizar a Gem com o SandBox, adicione a seguinte configuração no arquivo do environment que deseja utilizar.

### config/environments/development.rb

    MoIP.setup do |config|
      config.uri = "https://desenvolvedor.moip.com.br/sandbox"
      config.token = SEU_TOKEN
      config.key = SUA_KEY
    end

Após realizar os testes na SandBox, você poderá fazer a mudança para o ambiente de produção do MoIP de maneira simples. Basta inserir no arquivo de environment de produção o token e chave que serão utilizados. Por padrão a gem já utiliza a URI de produção do MoIP.

###Crie os dados do pagador

    pagador = { :nome => "Luiz Inácio Lula da Silva",
                :login_moip => "lula",
                :email => "presidente@planalto.gov.br",
                :tel_cel => "(61)9999-9999",
                :apelido => "Lula",
                :identidade => "111.111.111-11",
                :logradouro => "Praça dos Três Poderes",
                :numero => "0",
                :complemento => "Palácio do Planalto",
                :bairro => "Zona Cívico-Administrativa",
                :cidade => "Brasília",
                :estado => "DF",
                :pais => "BRA",
                :cep => "70100-000",
                :tel_fixo => "(61)3211-1221" }

###Dados do boleto

    boleto = { :valor => "50",
               :id_proprio => "Pag#{rand(1000)}",
               :forma => "BoletoBancario",
               :dias_expiracao => 5,
               :pagador => pagador }

###Checkout

    def checkout
      response = MoIP::Client.checkout(boleto)

      # exibe o boleto para impressão
      redirect_to MoIP::Client.moip_page(response["Token"])
    end

###Erros

 - MoIP::MissingPaymentTypeError - Quando falta a razão do pagamento na requisição.
 - MoIP::MissingPayerError - Quando falta as informações do pagador na requisição.
 - MoIP::WebServerResponseError - Quando há algum erro ao se enviar a solicitação ao servidor. Normalmente a razão do erro vem como resposta da mensagem.

## Futuras implementações

* Pagamento Simples
* Pagamento Recorrente


Baseado no projeto do [Daniel Lopes](http://github.com/danielvlopes/moip_usage).
