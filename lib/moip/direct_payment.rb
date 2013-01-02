# encoding: utf-8
require "nokogiri"

module MoIP

  # Baseado em http://labs.moip.com.br/pdfs/Integra%C3%A7%C3%A3o%20API%20-%20Autorizar%20e%20Cancelar%20Pagamentos.pdf
  CodigoErro = 0..999
  CodigoEstado = %w{AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO}
  CodigoMoeda = "BRL"
  CodigoPais = "BRA"
  Destino = %w{Nenhum MesmoCobranca AInformar PreEstabelecido}
  InstituicaoPagamento = %w{MoIP Visa AmericanExpress Mastercard Diners BancoDoBrasil Bradesco Itau BancoReal Unibanco Aura Hipercard Paggo Banrisul}
  FormaPagamento = %w{CarteiraMoIP CartaoCredito CartaoDebito DebitoBancario FinanciamentoBancario BoletoBancario}
  FormaRestricao = %w{Contador Valor}
  PapelIndividuo = %w{Integrador Recebedor Comissionado Pagado}
  OpcaoDisponivel = %w{Sim Não PagadorEscolhe}
  Parcelador = %w{Nenhum Administradora MoIP Recebedor}
  StatusLembrete = %w{Enviado Realizado EmAndamento Aguardando Falha}
  StatusPagamento = %w{Concluido EmAnalise Autorizado Iniciado Cancelado BoletoImpresso Estornado}
  TipoDias = %w{Corridos Uteis}
  TipoDuracao = %w{Minutos Horas Dias Semanas Meses Ano}
  TipoFrete = %w{Proprio Correio}
  TipoIdentidade = %w{CPF CNPJ}
  TipoInstrucao = %w{Unico Recorrente PrePago PosPago Remessa}
  TipoLembrete = %w{Email SMS}
  TipoPeriodicidade = %w{Anual Mensal Semanal Diaria}
  TipoRecebimento = %w{AVista Parcelado}
  TipoRestricao = %w{Autorizacao Pagamento}
  TipoStatus = %w{Sucesso Falha}
  
  #
  TiposComInstituicao = %w{CartaoCredito CartaoCredito DebitoBancario}

  class DirectPayment

    class << self

      # Cria uma instrução de pagamento direto
      def body(attributes = {})

#raise "#{attributes[:valor]}--#{attributes[:valor].to_f}"
        raise(MissingPaymentTypeError, "É necessário informar a razão do pagamento") if attributes[:razao].nil?
        raise(MissingPayerError, "É obrigatório passar as informarções do pagador") if attributes[:pagador].nil?

        raise(InvalidValue, "Valor deve ser maior que zero.") if attributes[:valor].to_f <= 0.0
        raise(InvalidPhone, "Telefone deve ter o formato (99)9999-9999.") if attributes[:pagador][:tel_fixo] !~ /\(\d{2}\)?\d{4}-\d{4}/
        raise(InvalidCellphone, "Telefone celular deve ter o formato (99)9999-9999.") if attributes[:pagador][:tel_cel] !~ /\(\d{2}\)?\d{4}-\d{4}/

        raise(MissingBirthdate, "É obrigatório passar as informarções do pagador") if TiposComInstituicao.include?(attributes[:forma]) && attributes[:data_nascimento].nil?

        raise(InvalidExpiry, "Data de expiração deve ter o formato 01-00 até 12-99.") if TiposComInstituicao.include?(attributes[:forma]) && attributes[:expiracao] !~ /(1[0-2]|0\d)\/\d{2}/


        raise(InvalidReceiving, "Recebimento é inválido. Escolha um destes: #{TipoRecebimento.join(', ')}") if !TipoRecebimento.include?(attributes[:recebimento]) && TiposComInstituicao.include?(attributes[:forma])

        raise(InvalidInstitution, "A instituição #{attributes[:instituicao]} é inválida. Escolha uma destas: #{InstituicaoPagamento.join(', ')}") if  TiposComInstituicao.include?(attributes[:forma]) && !InstituicaoPagamento.include?(attributes[:instituicao])

        builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|

          # Identificador do tipo de instrução
          xml.EnviarInstrucao {
            xml.InstrucaoUnica {

              # Dados da transação
              xml.Razao {
                xml.text attributes[:razao]
              }
              xml.Valores {
                xml.Valor(:moeda => "BRL") {
                  xml.text attributes[:valor]
                }
              }
              xml.IdProprio {
                xml.text attributes[:id_proprio]
              }

              # Definindo o pagamento direto
              xml.PagamentoDireto {
                xml.Forma {
                  xml.text attributes[:forma]
                }

                # Débito Bancário
                if ["DebitoBancario"].include?(attributes[:forma])
                  xml.Instituicao {
                    xml.text attributes[:instituicao]
                  }
                end

                # Cartão de Crédito
                if attributes[:forma] == "CartaoCredito"
                  xml.Instituicao {
                    xml.text attributes[:instituicao]
                  }
                  xml.CartaoCredito {
                    xml.Numero {
                      xml.text attributes[:numero]
                    }
                    xml.Expiracao {
                      xml.text attributes[:expiracao]
                    }
                    xml.CodigoSeguranca {
                      xml.text attributes[:codigo_seguranca]
                    }
                    xml.Portador {
                      xml.Nome {
                        xml.text attributes[:nome]
                      }
                      xml.Identidade(:Tipo => "CPF") {
                        xml.text attributes[:identidade]
                      }
                      xml.Telefone {
                        xml.text attributes[:telefone]
                      }
                      xml.DataNascimento {
                        xml.text attributes[:data_nascimento]
                      }
                    }
                  }
                  xml.Parcelamento {
                    xml.Parcelas {
                      xml.text attributes[:parcelas]
                    }
                    xml.Recebimento {
                      xml.text attributes[:recebimento]
                    }
                  }
                end
              }

              # Dados do pagador
              xml.Pagador {
                xml.Nome { xml.text attributes[:pagador][:nome] }
                xml.LoginMoIP { xml.text attributes[:pagador][:login_moip] }
                xml.Email { xml.text attributes[:pagador][:email] }
                xml.TelefoneCelular { xml.text attributes[:pagador][:tel_cel] }
                xml.Apelido { xml.text attributes[:pagador][:apelido] }
                xml.Identidade(:Tipo => "CPF") { xml.text attributes[:pagador][:identidade] }
                xml.EnderecoCobranca {
                  xml.Logradouro { xml.text attributes[:pagador][:logradouro] }
                  xml.Numero { xml.text attributes[:pagador][:numero] }
                  xml.Complemento { xml.text attributes[:pagador][:complemento] }
                  xml.Bairro { xml.text attributes[:pagador][:bairro] }
                  xml.Cidade { xml.text attributes[:pagador][:cidade] }
                  xml.Estado { xml.text attributes[:pagador][:estado] }
                  xml.Pais { xml.text attributes[:pagador][:pais] }
                  xml.CEP { xml.text attributes[:pagador][:cep] }
                  xml.TelefoneFixo { xml.text attributes[:pagador][:tel_fixo] }
                }
              }

              # Boleto Bancario
              if attributes[:forma] == "BoletoBancario"
                # Dados extras
                xml.Boleto {

                  xml.DiasExpiracao(:Tipo => "Corridos") {
                    xml.text attributes[:dias_expiracao]
                  }
                  xml.DataVencimento {
                    xml.text attributes[:data_vencimento]
                  }
                  xml.Instrucao1 {
                    xml.text attributes[:instrucao_1]
                  }
                  xml.URLLogo {
                    xml.text attributes[:url_logo]
                  }
                }
              end
              
              if attributes[:url_retorno]
                # URL de retorno
                xml.URLRetorno {
                  xml.text attributes[:url_retorno]
                }
              end
                
            }
          }
        end

        builder.to_xml
      end

    end

  end

end
