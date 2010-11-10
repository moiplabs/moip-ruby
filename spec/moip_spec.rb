# encoding: utf-8
require "moip"

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

    @billet = { :value => "8.90", :id_proprio => id, :forma => "BoletoBancario", :pagador => @pagador }
    @debit = { :value => "8.90", :id_proprio => id, :forma => "DebitoBancario", :instituicao => "BancoDoBrasil", :pagador => @pagador }
    @credit = { :value => "8.90", :id_proprio => id, :forma => "CartaoCredito", :instituicao => "AmericanExpress", :numero => "345678901234564", :expiracao => "08/11", :codigo_seguranca => "1234", :nome => "João Silva", :identidade => "134.277.017.00", :telefone => "(21)9208-0547", :data_nascimento => "25/10/1980", :parcelas => "2", :recebimento => "AVista", :pagador => @pagador }
  end

  context "make a billet checkout" do
    it "should have status Sucesso" do
      MoIP.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>{ "Resposta"=>{ "ID"=>Time.now.strftime("%y%m%d%H%M%S"), "Status"=>"Sucesso", "Token" => "T2N0L0X8E0S71217U2H3W1T4F4S4G4K731D010V0S0V0S080M010E0Q082X2" }})
      response = MoIP.checkout(@billet)
      response["Status"].should == "Sucesso"
    end
  end

  context "make a debit checkout" do
    it "should have status Sucesso" do
      MoIP.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>{ "Resposta"=>{ "ID"=>Time.now.strftime("%y%m%d%H%M%S"), "Status"=>"Sucesso", "Token" => "T2N0L0X8E0S71217U2H3W1T4F4S4G4K731D010V0S0V0S080M010E0Q082X2" }})
      response = MoIP.checkout(@debit)
      response["Status"].should == "Sucesso"
    end
  end

  context "make a debit checkout without pass a institution" do
    it "should have status Falha" do
      @incorrect_debit = { :value => "37.90", :id_proprio => id, :forma => "DebitoBancario", :pagador => @pagador }
      MoIP.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>{ "Resposta"=>{"Status"=>"Falha", "Erro"=>"Pagamento direto não é possível com a instituição de pagamento enviada" }})
      lambda { MoIP.checkout(@incorrect_debit) }.should raise_error(StandardError, "Pagamento direto não é possível com a instituição de pagamento enviada")
    end
  end

  context "make a debit checkout without pass the payer informations" do
    it "should raise an exception" do
      @incorrect_debit = { :value => "37.90", :id_proprio => id, :forma => "DebitoBancario", :instituicao => "BancoDoBrasil" }
      lambda { MoIP.checkout(@incorrect_debit) }.should raise_error(StandardError, "É obrigatório passar as informações do pagador")
    end
  end

  context "make a credit card checkout" do
    it "should have status Sucesso" do
      MoIP.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>{ "Resposta"=>{ "ID"=>Time.now.strftime("%y%m%d%H%M%S"), "Status"=>"Sucesso", "Token" => "T2N0L0X8E0S71217U2H3W1T4F4S4G4K731D010V0S0V0S080M010E0Q082X2" }})
      response = MoIP.checkout(@credit)
      response["Status"].should == "Sucesso"
    end
  end

  context "make a credit card checkout without pass card informations" do
    it "should have status Falha" do
      @incorrect_credit = { :value => "8.90", :id_proprio => id, :forma => "CartaoCredito", :pagador => @pagador }
      MoIP.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>{ "Resposta"=>{"Status"=>"Falha", "Erro"=>"Pagamento direto não é possível com a instituição de pagamento enviada" }})
      lambda { MoIP.checkout(@incorrect_credit) }.should raise_error(StandardError, "Pagamento direto não é possível com a instituição de pagamento enviada")
    end
  end

  context "in error scenario" do
    it "should raise an exception if response is nil" do
      MoIP.stub!(:post).and_return(nil)
      lambda { MoIP.checkout(@billet) }.should raise_error(StandardError, "Ocorreu um erro ao chamar o webservice")
    end

    it "should raise an exception if status is fail" do
      MoIP.stub!(:post).and_return("ns1:EnviarInstrucaoUnicaResponse"=>{ "Resposta"=>{"Status"=>"Falha", "Erro"=>"O status da resposta é Falha" }})
      lambda { MoIP.checkout(@billet) }.should raise_error(StandardError, "O status da resposta é Falha")
    end
  end

  context "query a transaction token" do
    it "should retrieve the transaction" do
      MoIP.stub!(:get).and_return("ns1:ConsultarTokenResponse"=>{ "RespostaConsultar"=>{"Status"=>"Sucesso", "ID"=>"201010291031001210000000046760" }})
      response = MoIP.query(token)
      response["Status"].should == "Sucesso"
    end
  end

  context "query a transaction token in a error scenario" do
    it "should retrieve status Falha" do
      MoIP.stub!(:get).and_return("ns1:ConsultarTokenResponse"=>{ "RespostaConsultar"=>{"Status"=>"Falha", "Erro"=>"Instrução não encontrada", "ID"=>"201010291102522860000000046768"}})
      lambda { MoIP.query("000000000000000000000000000000000000000000000000000000000000") }.should raise_error(StandardError, "Instrução não encontrada")
    end
  end

  context "build the MoIP URL" do
    it "should build the correct URL" do
      MoIP.moip_page(token).should == "https://desenvolvedor.moip.com.br/sandbox/Instrucao.do?token=#{token}"
    end

    it "should raise an error if the token is not informed" do
      lambda { MoIP.moip_page("").should raise_error(ArgumentError, "É necessário informar um token para retornar os dados da transação") }
    end

    it "should raise an error if nil is passed as the token" do
      lambda { MoIP.moip_page(nil).should raise_error(ArgumentError, "É necessário informar um token para retornar os dados da transação") }
    end
  end

  context "when receive notification" do
    before(:each) do
      @params = { "id_transacao" => "Pag62", "valor" => "8.90", "status_pagamento" => "3", "cod_moip" => "001", "forma_pagamento" => "73", "tipo_pagamento" => "BoletoBancario", "email_consumidor" => "presidente@planalto.gov.br" }
    end

    it "should return a hash with the params extracted from NASP" do
      response = { :transaction_id => "Pag62", :amount => "8.90", :status => "printed", :code => "001", :payment_type => "BoletoBancario", :email => "presidente@planalto.gov.br" }
      MoIP.notification(@params).should == response
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

end
