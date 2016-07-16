require 'spec_helper'


describe 'Cell, Unit' do

  let(:clazz) { CukeModeler::Cell }
  let(:cell) { clazz.new }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element'
    it_should_behave_like 'a sourced element'
    it_should_behave_like 'a raw element'

  end


  describe 'unique behavior' do

    it 'can be parsed from stand alone text' do
      source = 'a cell'

      expect { @model = clazz.new(source) }.to_not raise_error

      # Sanity check in case instantiation failed in a non-explosive manner
      expect(@model.value).to eq('a cell')
    end

    it 'can be instantiated with the minimum viable Gherkin' do
      source = ''

      expect { clazz.new(source) }.to_not raise_error
    end

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = "not a \n cell"

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_cell\.feature'/)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin4 => true do
      cell = clazz.new('a cell')
      raw_data = cell.raw_element

      expect(raw_data.keys).to match_array([:type, :location, :value])
      expect(raw_data[:type]).to eq(:TableCell)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin3 => true do
      cell = clazz.new("a cell")
      raw_data = cell.raw_element

      expect(raw_data.keys).to match_array([:type, :location, :value])
      expect(raw_data[:type]).to eq('TableCell')
    end

    it 'stores the original data generated by the parsing adapter', :gherkin2 => true do
      cell = clazz.new("a cell")
      raw_data = cell.raw_element

      # Cells did not exist as full fledged objects in the Gherkin2 parser
      expect(raw_data).to eq('a cell')
    end

    it 'has a value' do
      expect(cell).to respond_to(:value)
    end

    it 'can change its value' do
      expect(cell).to respond_to(:value=)

      cell.value = :some_value
      expect(cell.value).to eq(:some_value)
      cell.value = :some_other_value
      expect(cell.value).to eq(:some_other_value)
    end


    describe 'model population' do

      context 'from source text' do

        let(:source_text) { 'a cell' }
        let(:cell) { clazz.new(source_text) }


        it "models the cell's value" do
          expect(cell.value).to eq('a cell')
        end

      end

    end


    describe 'abstract instantiation' do

      context 'a new cell object' do

        let(:cell) { clazz.new }


        it 'starts with no value' do
          expect(cell.value).to eq('')
        end

      end

    end


    describe 'cell output' do

      it 'is a String' do
        expect(cell.to_s).to be_a(String)
      end


      context 'from source text' do

        it 'can output a cell' do
          source = 'a cell'
          cell = clazz.new(source)

          expect(cell.to_s).to eq('a cell')
        end

        #  Because vertical bars mark the beginning and end of a cell, any vertical bars inside
        #  of the cell (which would have had to have been escaped to get inside of the cell in
        #  the first place) will be escaped when outputted so as to retain the quality of being
        #  able to use the output directly as Gherkin.

        it 'can output a cell that has vertical bars in it' do
          source = 'cell with a \| in it'
          cell = clazz.new(source)

          cell_output = cell.to_s

          expect(cell_output).to eq('cell with a \| in it')
        end

        #  Because backslashes are used to escape special characters, any backslashes inside
        #  of the cell (which would have had to have been escaped to get inside of the cell in
        #  the first place) will be escaped when outputted so as to retain the quality of being
        #  able to use the output directly as Gherkin.

        it 'can output a cell that has backslashes in it' do
          source = 'cell with a \\\\ in it'
          cell = clazz.new(source)

          cell_output = cell.to_s

          expect(cell_output).to eq('cell with a \\\\ in it')
        end

        # Depending on the order in which special characters are escaped, extra backslashes might occur.
        it 'can output a cell that has several kinds of special characters in it' do
          source = 'cell with a \\\\ and \| in it'
          cell = clazz.new(source)

          cell_output = cell.to_s

          expect(cell_output).to eq('cell with a \\\\ and \| in it')
        end

      end

      context 'from abstract instantiation' do

        let(:cell) { clazz.new }


        it 'can output an empty cell' do
          expect { cell.to_s }.to_not raise_error
        end

      end

    end

  end

end
