require 'spec_helper'

module Omnibus
  describe Digestable do
    let(:path) { '/path/to/file' }
    let(:io)   { StringIO.new }

    subject { Class.new { include Digestable }.new }

    describe '#digest' do
      it 'reads the IO in chunks' do
        expect(File).to receive(:open).with(path).and_yield(io)
        expect(subject.digest(path)).to eq('d41d8cd98f00b204e9800998ecf8427e')
      end
    end

    describe '#digest_directory' do
      let(:path)    { '/path/to/dir' }
      let(:glob)    { "#{path}/**/*" }
      let(:subdir)  { '/path/to/dir/subdir' }
      let(:subfile) { '/path/to/dir/subfile' }
      let(:io)      { StringIO.new }

      it 'inspects the file types of glob entries' do
        expect(Dir).to receive(:glob).with(glob).and_return([subdir])
        expect(File).to receive(:ftype).with(subdir).and_return('directory')
        expect(subject.digest_directory(path)).to eq('d4635f6b4c2a85ba603e1f9e6a65bd68')
      end

      it 'inspects the contents of the files' do
        expect(Dir).to receive(:glob).with(glob).and_return([subfile])
        expect(File).to receive(:ftype).with(subfile).and_return('file')
        expect(File).to receive(:open).with(subfile).and_yield(io)
        expect(subject.digest_directory(path)).to eq('73d045a78027e674811c36f3dbd09433')
      end
    end
  end
end
