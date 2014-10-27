require 'spec_helper'

RSpec.describe Pdfinfo do
  let(:pdf_path) { fixture_path('pdfs/test.pdf') }
  let(:pdfinfo) { described_class.new(pdf_path) }
  let(:encrypted_response) { File.read(fixture_path('shell_responses/encrypted.txt')).chomp }
  let(:unencrypted_response) { File.read(fixture_path('shell_responses/test.txt')).chomp }
  let(:mock_response) { unencrypted_response }

  specify "mock responses match" do
    expect(`pdfinfo -upw foo #{fixture_path('pdfs/encrypted.pdf')}`.chomp).to eq(encrypted_response)
    expect(`pdfinfo #{fixture_path('pdfs/test.pdf')}`.chomp).to eq(unencrypted_response)
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

  describe '#title' do
    context 'when given a title' do
      it 'returns the title' do
        expect(pdfinfo.title).to eq('Pdfinfo Title')
      end
    end
    context 'when title is not present' do
      let(:mock_response) { "Title: \n" }
      it 'returns nil' do
        expect(pdfinfo.title).to be_nil
      end
    end
  end

  describe '#subject' do
    context 'when given a subject' do
      it 'returns the subject' do
        expect(pdfinfo.subject).to eq('Pdfinfo Subject')
      end
    end
    context 'when title is not present' do
      let(:mock_response) { "Subject: \n" }
      it 'returns nil' do
        expect(pdfinfo.title).to be_nil
      end
    end
  end

  describe '#keywords' do
    context 'when given keywords' do
      it 'returns the keywords' do
        expect(pdfinfo.keywords).to eq(['Keyword1', 'Keyword2'])
      end
    end
    context 'when title is not present' do
      let(:mock_response) { "Keywords: \n" }
      it 'returns an empty array' do
        expect(pdfinfo.keywords).to eq([])
      end
    end
  end

  describe '#author' do
    context 'when given an author' do
      it 'returns the author' do
        expect(pdfinfo.author).to eq('Pdfinfo Author')
      end
    end
    context 'when title is not present' do
      let(:mock_response) { "Author: \n" }
      it 'returns nil' do
        expect(pdfinfo.title).to be_nil
      end
    end
  end

  describe '#creation_date' do
    context 'when given an author' do
      it 'returns a time object' do
        expect(pdfinfo.creation_date).to be_an_instance_of(Time)
      end
      it 'returns the time correctly parsed' do
        expect(pdfinfo.creation_date).to eq(Time.parse("2014-10-26 18:23:25 -0700"))
      end
    end
    context 'when creation date is not present' do
      let(:mock_response) { "CreationDate: \n" }
      it 'returns nil' do
        expect(pdfinfo.creation_date).to be_nil
      end
    end
  end

  describe '#creator' do
    context 'when given a creator' do
      it { expect(pdfinfo.creator).to eq('Pdfinfo Creator') }
    end
    context 'when creator is not present' do
      let(:mock_response) { "Creator: \n" }
      it { expect(pdfinfo.creator).to be_nil }
    end
  end

  describe '#producer' do
    context 'when given a creator' do
      it { expect(pdfinfo.producer).to eq('Pdfinfo Producer') }
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
      expect(pdfinfo.page_count).to eq(5)
    end
  end

  describe 'encrypted?' do
    context 'given encrypted pdf' do
      let(:mock_response) { encrypted_response }
      it { expect(pdfinfo.encrypted?).to eq(true) }
    end
    context 'given unencrypted pdf' do
      let(:mock_response) { unencrypted_response }
      it { expect(pdfinfo.encrypted?).to eq(false) }
    end
  end

  describe 'width' do
    it { expect(pdfinfo.width).to eq(595.28) }
  end

  describe 'height' do
    it { expect(pdfinfo.height).to eq(841.89) }
  end

  describe 'size' do
    it 'returns a fixnm value for the file size in bytes' do
      expect(pdfinfo.file_size).to eq(2867)
    end
  end

  describe 'pdf_version' do
    it 'returns a string value for the PDF spec version' do
      expect(pdfinfo.pdf_version).to eq('1.3')
    end
  end
end