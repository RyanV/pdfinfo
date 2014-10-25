require 'spec_helper'

RSpec.describe Pdfinfo do
  let(:pdf_path) { fixture_path('test.pdf') }
  let(:pdfinfo) { described_class.new(pdf_path) }
  let(:mock_response) { File.read(fixture_path('shell_response.txt')).chomp }

  before(:suite) do
    # validate that our mock response matches the real response
    expect(described_class.exec(pdf_path)).to eq(mock_response)
  end

  before(:each) do
    allow(described_class).to receive(:exec).and_return(mock_response)
  end

  describe 'pdfinfo_command' do
    it "falls back to pdfinfo" do
      Pdfinfo.pdfinfo_command = nil
      expect(Pdfinfo.pdfinfo_command).to eq('pdfinfo')
    end

    it 'allows the command to be changed' do
      Pdfinfo.pdfinfo_command = '/another/bin/path/pdfinfo'
      expect(Pdfinfo.pdfinfo_command).to eq('/another/bin/path/pdfinfo')
    end
  end

  describe '#creator' do
    context 'when given a creator' do
      it { expect(pdfinfo.creator).to eq('Prawn') }
    end
    context 'when creator is not present' do
      let(:mock_response) { "Creator: \n" }
      it { expect(pdfinfo.creator).to be_nil }
    end
  end

  describe '#producer' do
    context 'when given a creator' do
      it { expect(pdfinfo.producer).to eq('Prawn') }
    end
    context 'when creator is not present' do
      let(:mock_response) { "Producer: \n" }
      it { expect(pdfinfo.producer).to be_nil }
    end
  end

  describe 'tagged?' do
    context 'when tagged' do
      let(:mock_response) { "Tagged: yes" }
      it { expect(pdfinfo.tagged?).to eq(true) }
    end
    context 'when not tagged' do
      let(:mock_response) { "Tagged: no" }
      it { expect(pdfinfo.tagged?).to eq(false) }
    end
  end

  describe '#form' do
    it { expect(pdfinfo.form).to eq('none') }
  end

  describe 'page_count' do
    it 'returns a fixnum value of the number of pages' do
      expect(pdfinfo.page_count).to eq(3)
    end
  end

  describe 'encrypted?' do
    context 'given encrypted pdf' do
      let(:mock_response) { "Encrypted: yes\n" }
      it { expect(pdfinfo.encrypted?).to eq(true) }
    end
    context 'given unencrypted pdf' do
      let(:mock_response) { 'Encrypted: no' }
      it { expect(pdfinfo.encrypted?).to eq(false) }
    end
  end

  describe 'width' do
    it { expect(pdfinfo.width).to eq(612) }
  end

  describe 'height' do
    it { expect(pdfinfo.height).to eq(792) }
  end

  describe 'size' do
    it 'returns a fixnm value for the file size in bytes' do
      expect(pdfinfo.file_size).to eq(1521)
    end
  end

  describe 'pdf_version' do
    it 'returns a string value for the PDF spec version' do
      expect(pdfinfo.pdf_version).to eq('1.3')
    end
  end
end