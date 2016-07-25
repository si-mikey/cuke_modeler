require 'spec_helper'


describe 'Row, Unit' do

  let(:clazz) { CukeModeler::Row }
  let(:row) { clazz.new }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element'
    it_should_behave_like 'a sourced element'
    it_should_behave_like 'a parsed element'

  end


  # todo - move some of these test because they are now integration tests due to using the Cell class
  describe 'unique behavior' do

    it 'can be instantiated with the minimum viable Gherkin' do
      source = '| a | row |'

      expect { clazz.new(source) }.to_not raise_error
    end

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = " |bad |row| text| \n @foo "

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_row\.feature'/)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin4 => true do
      example_row = clazz.new("| a | row |")
      raw_data = example_row.parsing_data

      expect(raw_data.keys).to match_array([:type, :location, :cells])
      expect(raw_data[:type]).to eq(:TableRow)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin3 => true do
      example_row = clazz.new("| a | row |")
      raw_data = example_row.parsing_data

      expect(raw_data.keys).to match_array([:type, :location, :cells])
      expect(raw_data[:type]).to eq('TableRow')
    end

    it 'stores the original data generated by the parsing adapter', :gherkin2 => true do
      example_row = clazz.new("| a | row |")
      raw_data = example_row.parsing_data

      expect(raw_data.keys).to match_array(['cells', 'line', 'id'])
      expect(raw_data['line']).to eq(6)
    end

    it 'has cells' do
      expect(row).to respond_to(:cells)
    end

    it 'can change its cells' do
      expect(row).to respond_to(:cells=)

      row.cells = :some_cells
      expect(row.cells).to eq(:some_cells)
      row.cells = :some_other_cells
      expect(row.cells).to eq(:some_other_cells)
    end


    describe 'model population' do

      context 'from source text' do

        let(:source_text) { '| cell 1 | cell 2 |' }
        let(:row) { clazz.new(source_text) }


        it "models the row's cells" do
          cell_values = row.cells.collect { |cell| cell.value }

          expect(cell_values).to match_array(['cell 1', 'cell 2'])
        end

      end

    end


    describe 'abstract instantiation' do

      context 'a new row object' do

        let(:row) { clazz.new }


        it 'starts with no cells' do
          expect(row.cells).to eq([])
        end

      end

    end


    describe 'row output' do

      it 'is a String' do
        expect(row.to_s).to be_a(String)
      end

      context 'from source text' do

        it 'can output a row' do
          source = ['| some value |']
          source = source.join("\n")
          row = clazz.new(source)

          row_output = row.to_s.split("\n")

          expect(row_output).to eq(['| some value |'])
        end

        it 'can output a row with multiple cells' do
          source = ['| some value | some other value |']
          source = source.join("\n")
          row = clazz.new(source)

          row_output = row.to_s.split("\n")

          expect(row_output).to eq(['| some value | some other value |'])
        end

      end

      context 'from abstract instantiation' do

        let(:row) { clazz.new }


        it 'can output an empty row' do
          expect { row.to_s }.to_not raise_error
        end

      end

    end

  end

end
