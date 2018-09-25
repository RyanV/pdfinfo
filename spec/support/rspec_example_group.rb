class Pdfinfo
  module RSpec
    module ExampleGroup
      module ClassMethods
        def self.extended(host)
          host.class_eval do
            let(:user_password) { nil }
            let(:encrypted_pdf_path) { fixture_path('pdfs/encrypted.pdf') }
            let(:unencrypted_pdf_path) { fixture_path('pdfs/unencrypted.pdf') }

            let(:pdfinfo) { described_class.new(pdf_path, user_password: user_password) }
            let(:modified_pdfinfo) do
              lambda do |&modification_handler|
                described_class.new(
                  pdf_path,
                  user_password: user_password,
                  response_mapper: lambda do |response|
                    modifier = Pdfinfo::ResponseModifier.new(response)
                    modification_handler.call(modifier)
                    modifier.to_s
                  end
                )
              end
            end
          end
        end

        def use_encrypted!
          let(:user_password) { 'foo' }
          let(:pdf_path) { encrypted_pdf_path }
        end

        def use_unencrypted!
          let(:pdf_path) { unencrypted_pdf_path }
        end
      end
    end
  end
end