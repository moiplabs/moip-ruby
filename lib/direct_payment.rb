# encoding: utf-8
module MoIP

  class DirectPayment

    class << self

      # Cria uma instrução de pagamento direto
      def body(attributes = {})
        builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|

          # Identificador do tipo de instrução
          xml.EnviarInstrucao {
            xml.InstrucaoUnica {
              # Dados da transação
              xml.Razao {
                xml.text "Pagamento"
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
                if attributes[:forma] == "DebitoBancario"
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
              raise(StandardError, "É obrigatório passar as informações do pagador") if attributes[:pagador].nil?
              xml.Pagador {
                xml.Nome { xml.text attributes[:pagador][:nome] }
                xml.LoginMoIP { xml.text attributes[:pagador][:login_moip] }
                xml.Email { xml.text attributes[:pagador][:email] }
                xml.TelefoneCelular { xml.text attributes[:pagador][:tel_cel] }
                xml.Apelido { xml.text attributes[:pagador][:apelido] }
                xml.Identidade { xml.text attributes[:pagador][:identidade] }
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
                  xml.Instrucao1 {
                    xml.text attributes[:instrucao_1]
                  }
                  xml.URLLogo {
                    xml.text attributes[:url_logo]
                  }
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
