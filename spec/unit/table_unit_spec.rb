require 'spec_helper'


describe 'Table, Unit' do

  let(:clazz) { CukeModeler::Table }
  let(:table) { clazz.new }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element'
    it_should_behave_like 'a parsed element'
    it_should_behave_like 'a sourced element'

  end


  describe 'unique behavior' do

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = 'bad table text'

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_table\.feature'/)
    end

    it 'has rows' do
      expect(table).to respond_to(:rows)
    end

    it 'can get and set its row elements' do
      expect(table).to respond_to(:rows=)

      table.rows = :some_row_elements
      expect(table.rows).to eq(:some_row_elements)
      table.rows = :some_other_row_elements
      expect(table.rows).to eq(:some_other_row_elements)
    end


    describe 'abstract instantiation' do

      context 'a new table object' do

        let(:table) { clazz.new }


        it 'starts with no rows' do
          expect(table.rows).to eq([])
        end

      end

    end

    it 'contains rows' do
      rows = [:row_1, :row_2]
      everything = rows

      table.rows = rows

      expect(table.children).to match_array(everything)
    end


    describe 'table output' do

      it 'is a String' do
        table.to_s.should be_a(String)
      end


      context 'from abstract instantiation' do

        let(:table) { clazz.new }


        it 'can output an empty table' do
          expect { table.to_s }.to_not raise_error
        end

      end

    end

  end

end
