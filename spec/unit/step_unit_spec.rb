require 'spec_helper'


describe 'Step, Unit' do

  let(:clazz) { CukeModeler::Step }
  let(:step) { clazz.new }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element'
    it_should_behave_like 'a sourced element'
    it_should_behave_like 'a parsed element'

  end


  describe 'unique behavior' do

    it 'has text' do
      expect(step).to respond_to(:text)
    end

    it 'can change its text' do
      expect(step).to respond_to(:text=)

      step.text = :some_text
      expect(step.text).to eq(:some_text)
      step.text = :some_other_text
      expect(step.text).to eq(:some_other_text)
    end

    it 'has a block' do
      expect(step).to respond_to(:block)
    end

    it 'can change its block' do
      expect(step).to respond_to(:block=)

      step.block = :some_block
      expect(step.block).to eq(:some_block)
      step.block = :some_other_block
      expect(step.block).to eq(:some_other_block)
    end

    it 'has a keyword' do
      expect(step).to respond_to(:keyword)
    end

    it 'can change its keyword' do
      expect(step).to respond_to(:keyword=)

      step.keyword = :some_keyword
      expect(step.keyword).to eq(:some_keyword)
      step.keyword = :some_other_keyword
      expect(step.keyword).to eq(:some_other_keyword)
    end


    describe 'abstract instantiation' do

      context 'a new step object' do

        let(:step) { clazz.new }


        it 'starts with no text' do
          expect(step.text).to be_nil
        end

        it 'starts with no block' do
          expect(step.block).to be_nil
        end

        it 'starts with no keyword' do
          expect(step.keyword).to be_nil
        end

      end

    end

    it 'contains some kind of block' do
      block = :block
      everything = [block]

      step.block = block

      expect(step.children).to match_array(everything)
    end


    describe 'step output' do

      it 'is a String' do
        expect(step.to_s).to be_a(String)
      end


      context 'from abstract instantiation' do

        let(:step) { clazz.new }


        it 'can output an empty step' do
          expect { step.to_s }.to_not raise_error
        end

        it 'can output a step that has only a keyword' do
          step.keyword = '*'

          expect { step.to_s }.to_not raise_error
        end

        it 'can output a step that has only a text' do
          step.text = 'step text'

          expect { step.to_s }.to_not raise_error
        end

      end

    end

    it 'can gracefully be compared to other types of objects' do
      # Some common types of object
      [1, 'foo', :bar, [], {}].each do |thing|
        expect { step == thing }.to_not raise_error
        expect(step == thing).to be false
      end
    end

  end

end
