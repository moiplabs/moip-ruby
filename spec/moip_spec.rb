# encoding: utf-8
require "moip"

require "digest/sha1"

describe "Make payments with the MoIP API" do

  before :all do

    @pagador = { :nome => "Luiz Inácio Lula da Silva",
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

    @billet_without_razao = { :value => "8.90", :id_proprio => id,
                              :forma => "BoletoBancario", :pagador => @pagador}
    @billet = { :value => "8.90", :id_proprio => id,
                :forma => "BoletoBancario", :pagador => @pagador ,
                :razao=> "Pagamento" }

    @debit = { :value => "8.90", :id_proprio => id, :forma => "DebitoBancario",
               :instituicao => "BancoDoBrasil", :pagador => @pagador,
               :razao => "Pagamento"}

    @credit = { :value => "8.90", :id_proprio => id, :forma => "CartaoCredito",
                :instituicao => "AmericanExpress",:numero => "345678901234564",
                :expiracao => "08/11", :codigo_seguranca => "1234",
                :nome => "João Silva", :identidade => "134.277.017.00",
                :telefone => "(21)9208-0547", :data_nascimento => "25/10/1980",
                :parcelas => "2", :recebimento => "AVista",
                :pagador => @pagador, :razao => "Pagamento"}
  end

  context "misconfigured" do
    it "should raise a missing config error " do
      MoIP::Client # for autoload
      lambda { MoIP::Client.checkout(@billet) }.should raise_error(MoIP::MissingConfigError)
    end

    it "should raise a missing token error when token is nil" do
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = nil
        config.key = 'key'
      end
      
      MoIP::Client # for autoload
      lambda { MoIP::Client.checkout(@billet) }.should raise_error(MoIP::MissingTokenError)
    end

    it "should raise a missing key error when key is nil" do
      
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = 'token'
        config.key = nil
      end
      
      MoIP::Client # for autoload
      lambda { MoIP::Client.checkout(@billet) }.should raise_error(MoIP::MissingKeyError)
    end



    it "should raise a missing token error when token is empty" do
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = ''
        config.key = 'key'
      end
      
      MoIP::Client # for autoload
      lambda { MoIP::Client.checkout(@billet) }.should raise_error(MoIP::MissingTokenError)
    end

    it "should raise a missing key error when key is empty" do
      
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = 'token'
        config.key = ''
      end
      
      MoIP::Client # for autoload
      lambda { MoIP::Client.checkout(@billet) }.should raise_error(MoIP::MissingKeyError)
    end
  end
  
  context "checkout" do
    before(:each) do
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = 'token'
        config.key = 'key'
      end
      MoIP::Client.stub!(:post).
          and_return("ns1:EnviarInstrucaoUnicaResponse"=>
                     { "Resposta"=>
                        { "ID"=>Time.now.strftime("%y%m%d%H%M%S"),
                          "Status"=>"Sucesso",
                          "Token" => "T2N0L0X8E0S71217U2H3W1T4F4S4G4K731D010V0S0V0S080M010E0Q082X2"
                        }
                     })
    end
  
    it "with old api should be deprecated" do
      deprecations = collect_deprecations{ MoIP.checkout(@billet) }
  
      deprecations.should_not be_empty
      deprecations.any? {|w| w =~ /MoIP.checkout has been deprecated/ }.should be_true
    end
  
    context "when it is a billet checkout" do
      before(:each) do
        MoIP.setup do |config|
          config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
          config.token = 'token'
          config.key = 'key'
        end
      end
      it "should raise an exception when razao parameter is not passed" do
        error = "É necessário informar a razão do pagamento"
  
        lambda { MoIP::Client.checkout(@billet_without_razao) }.should raise_error(MoIP::MissingPaymentTypeError,error)
      end
  
      it "should have status 'Sucesso'" do
        response = MoIP::Client.checkout(@billet)
        response["Status"].should == "Sucesso"
      end
    end
  
    context "when it is a debit checkout" do
      before(:each) do
        MoIP.setup do |config|
          config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
          config.token = 'token'
          config.key = 'key'
        end
      end
      it "should have status 'Sucesso' with valid arguments" do
        response = MoIP::Client.checkout(@debit)
        response["Status"].should == "Sucesso"
      end
  
      it "should have status 'Falha' when a instituition is not passed as argument" do
        @incorrect_debit = { :value => "37.90", :id_proprio => id,
                             :forma => "DebitoBancario", :pagador => @pagador,
                             :razao => "Pagamento"}
  
        error = "Pagamento direto não é possível com a instituição de pagamento enviada"
  
        MoIP::Client.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>
                            { "Resposta"=>
                                {
                                 "Status"=>"Falha",
                                 "Erro"=>error
                                }
                            })
        error = "Pagamento direto não é possível com a instituição de pagamento enviada"
        lambda { MoIP::Client.checkout(@incorrect_debit) }.should
            raise_error(MoIP::WebServerResponseError, error)
      end
  
      it "should raise an exception if payer informations were not passed" do
        @incorrect_debit = { :value => "37.90", :id_proprio => id,
                             :forma => "DebitoBancario",
                             :instituicao => "BancoDoBrasil",
                             :razao => "Pagamento"
                           }
  
        lambda { MoIP::Client.checkout(@incorrect_debit) }.should
            raise_error(MoIP::MissingPayerError, "É obrigatório passar as informações do pagador")
      end
    end
  
    context "when it is a credit card checkout" do
      before(:each) do
        MoIP.setup do |config|
          config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
          config.token = 'token'
          config.key = 'key'
        end
      end
      it "should have status 'Sucesso' with valid arguments" do
        response = MoIP::Client.checkout(@credit)
        response["Status"].should == "Sucesso"
      end
  
      it "should have status 'Falha' when the card informations were not passed as argument" do
        @incorrect_credit = { :value => "8.90", :id_proprio => id,
                              :forma => "CartaoCredito", :pagador => @pagador,
                              :razao => "Pagamento"
                            }
  
        error = "Pagamento direto não é possível com a instituição de pagamento enviada"
        MoIP::Client.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>
                        {
                        "Resposta"=>
                            {
                             "Status"=>"Falha",
                             "Erro"=>error
                            }
                        })
  
        error = "Pagamento direto não é possível com a instituição de pagamento enviada"
        lambda { MoIP::Client.checkout(@incorrect_credit) }.should
            raise_error(MoIP::WebServerResponseError, error)
      end
    end
  
    context "in error scenario" do
      before(:each) do
        MoIP.setup do |config|
          config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
          config.token = 'token'
          config.key = 'key'
        end
      end
      it "should raise an exception if response is nil" do
        MoIP::Client.stub!(:post).and_return(nil)
        lambda { MoIP::Client.checkout(@billet) }.should
            raise_error(StandardError,"Ocorreu um erro ao chamar o webservice")
      end
  
      it "should raise an exception if status is fail" do
        MoIP::Client.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>
                        { "Resposta"=>
                            {"Status"=>"Falha",
                             "Erro"=>"O status da resposta é Falha"
                            }
                        })
  
        lambda { MoIP::Client.checkout(@billet) }.should raise_error(StandardError, "O status da resposta é Falha")
      end
    end
  end
  
  context "query a transaction token" do
    
    before(:each) do
  
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = 'token'
        config.key = 'key'
      end
      MoIP::Client.stub!(:get).and_return("ns1:ConsultarTokenResponse"=>
                    { "RespostaConsultar"=>
                        {"Status"=>"Sucesso",
                         "ID"=>"201010291031001210000000046760"
                        }
                    })
    end
  
    it "with old api should be deprecated" do
      deprecations = collect_deprecations{ MoIP.query(token) }
  
      deprecations.should_not be_empty
      deprecations.any? {|w| w =~ /MoIP.query has been deprecated/ }.should be_true
    end
  
    it "should retrieve the transaction" do
      response = MoIP::Client.query(token)
      response["Status"].should == "Sucesso"
    end
  
    context "in a error scenario" do
      before(:each) do
        MoIP.setup do |config|
          config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
          config.token = 'token'
          config.key = 'key'
        end
      end
      it "should retrieve status 'Falha'" do
        MoIP::Client.stub!(:get).and_return("ns1:ConsultarTokenResponse"=>
                        { "RespostaConsultar"=>
                            {"Status"=>"Falha",
                             "Erro"=>"Instrução não encontrada",
                             "ID"=>"201010291102522860000000046768"
                            }
                        })
        query = "000000000000000000000000000000000000000000000000000000000000"
        lambda { MoIP::Client.query(query) }.should raise_error(StandardError, "Instrução não encontrada")
      end
    end
  end
  
  context "build the MoIP URL" do
    before(:each) do
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = 'token'
        config.key = 'key'
      end
    end
    it "with old api should be deprecated" do
      deprecations = collect_deprecations{ MoIP.moip_page(token) }
  
      deprecations.should_not be_empty
      deprecations.any? {|w| w =~ /MoIP.moip_page has been deprecated/ }.should be_true
    end
  
    it "should build the correct URL" do
      page = "https://desenvolvedor.moip.com.br/sandbox/Instrucao.do?token=#{token}"
      MoIP::Client.moip_page(token).should ==  page
    end
  
    it "should raise an error if the token is not informed" do
      error = "É necessário informar um token para retornar os dados da transação"
      lambda { MoIP::Client.moip_page("").should
          raise_error(ArgumentError, error) }
    end
  
    it "should raise an error if nil is passed as the token" do
      error = "É necessário informar um token para retornar os dados da transação"
      lambda { MoIP::Client.moip_page(nil).should
          raise_error(ArgumentError, error) }
    end
  
    it "should raise a missing token error if nil is passed as the token" do
      lambda { MoIP::Client.moip_page(nil).should raise_error(MissingTokenError) }
    end
  
    it "should raise a missing token error if an empty string is passed as the token" do
      lambda { MoIP::Client.moip_page("").should raise_error(MissingTokenError) }
    end
  end
  
  context "when receive notification" do
    before(:each) do
      MoIP.setup do |config|
        config.uri = 'https://desenvolvedor.moip.com.br/sandbox'
        config.token = 'token'
        config.key = 'key'
      end
      @params = { "id_transacao" => "Pag62", "valor" => "8.90",
                  "status_pagamento" => "3", "cod_moip" => "001",
                  "forma_pagamento" => "73", "tipo_pagamento" => "BoletoBancario",
                  "email_consumidor" => "presidente@planalto.gov.br" }
    end
  
    it "with old api should be deprecated" do
      deprecations = collect_deprecations{ MoIP.notification(@param) }
  
      deprecations.should_not be_empty
      deprecations.any? {|w| w =~ /MoIP.notification has been deprecated/ }.should be_true
    end
  
    it "should return a hash with the params extracted from NASP" do
      response = { :transaction_id => "Pag62", :amount => "8.90",
                   :status => "printed", :code => "001",
                   :payment_type => "BoletoBancario",
                   :email => "presidente@planalto.gov.br" }
  
      MoIP::Client.notification(@params).should == response
    end
  
    it "should return valid status based on status code" do
      MoIP::STATUS[1].should == "authorized"
      MoIP::STATUS[2].should == "started"
      MoIP::STATUS[3].should == "printed"
      MoIP::STATUS[4].should == "completed"
      MoIP::STATUS[5].should == "canceled"
      MoIP::STATUS[6].should == "analysing"
    end
  end
  
  def id
    "transaction_" + Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
  def token
    "T2X0Q1N021E0B2S9U1P0V3Y0G1F570Y2P4M0P000M0Z0F0J0G0U4N6C7W5T9"
  end
  
  def collect_deprecations
    old_behavior = ActiveSupport::Deprecation.behavior
    deprecations = []
    ActiveSupport::Deprecation.behavior = Proc.new do |message, callstack|
      deprecations << message
    end
    result = yield
    deprecations
  ensure
    ActiveSupport::Deprecation.behavior = old_behavior
  end
end
