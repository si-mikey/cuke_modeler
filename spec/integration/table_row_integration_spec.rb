require 'spec_helper'


describe 'TableRow, Integration' do

  let(:clazz) { CukeModeler::TableRow }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element, integration'

  end


  describe 'unique behavior' do

    it 'properly sets its child elements' do
      source = '| cell 1 | cell 2 |'

      row = clazz.new(source)
      cell_1 = row.cells.first
      cell_2 = row.cells.last

      expect(cell_1.parent_model).to equal(row)
      expect(cell_2.parent_model).to equal(row)
    end


    describe 'getting ancestors' do

      before(:each) do
        source = ['Feature: Test feature',
                  '',
                  '  Scenario: Test test',
                  '    * a step:',
                  '      | a | table |']
        source = source.join("\n")

        file_path = "#{@default_file_directory}/table_row_test_file.feature"
        File.open(file_path, 'w') { |file| file.write(source) }
      end

      let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
      let(:table_row) { directory.feature_files.first.feature.tests.first.steps.first.block.rows.first }


      it 'can get its directory' do
        ancestor = table_row.get_ancestor(:directory)

        ancestor.should equal directory
      end

      it 'can get its feature file' do
        ancestor = table_row.get_ancestor(:feature_file)

        ancestor.should equal directory.feature_files.first
      end

      it 'can get its feature' do
        ancestor = table_row.get_ancestor(:feature)

        ancestor.should equal directory.feature_files.first.feature
      end

      context 'a table row that is part of a scenario' do

        before(:each) do
          source = 'Feature: Test feature
                    
                      Scenario: Test test
                        * a step:
                          | a | table |'

          file_path = "#{@default_file_directory}/doc_string_test_file.feature"
          File.open(file_path, 'w') { |file| file.write(source) }
        end

        let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
        let(:table_row) { directory.feature_files.first.feature.tests.first.steps.first.block.rows.first }


        it 'can get its scenario' do
          ancestor = table_row.get_ancestor(:scenario)

          expect(ancestor).to equal(directory.feature_files.first.feature.tests.first)
        end

      end

      context 'a table row that is part of an outline' do

        before(:each) do
          source = 'Feature: Test feature
                    
                      Scenario Outline: Test outline
                        * a step:
                          | a | table |
                      Examples:
                        | param |
                        | value |'

          file_path = "#{@default_file_directory}/doc_string_test_file.feature"
          File.open(file_path, 'w') { |file| file.write(source) }
        end

        let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
        let(:table_row) { directory.feature_files.first.feature.tests.first.steps.first.block.rows.first }


        it 'can get its outline' do
          ancestor = table_row.get_ancestor(:outline)

          expect(ancestor).to equal(directory.feature_files.first.feature.tests.first)
        end

      end

      context 'a table row that is part of a background' do

        before(:each) do
          source = 'Feature: Test feature
                    
                      Background: Test background
                        * a step:
                          | a | table |'

          file_path = "#{@default_file_directory}/doc_string_test_file.feature"
          File.open(file_path, 'w') { |file| file.write(source) }
        end

        let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
        let(:table_row) { directory.feature_files.first.feature.background.steps.first.block.rows.first }


        it 'can get its background' do
          ancestor = table_row.get_ancestor(:background)

          expect(ancestor).to equal(directory.feature_files.first.feature.background)
        end

      end

      it 'can get its step' do
        ancestor = table_row.get_ancestor(:step)

        ancestor.should equal directory.feature_files.first.feature.tests.first.steps.first
      end

      it 'can get its table' do
        ancestor = table_row.get_ancestor(:table)

        ancestor.should equal directory.feature_files.first.feature.tests.first.steps.first.block
      end

      it 'returns nil if it does not have the requested type of ancestor' do
        ancestor = table_row.get_ancestor(:example)

        ancestor.should be_nil
      end

    end


    describe 'model population' do

      context 'from source text' do

        it "models the table row's source line" do
          source_text = "Feature:

                           Scenario:
                             * a step
                               | foo |"
          row = CukeModeler::Feature.new(source_text).tests.first.steps.first.block.rows.first

          expect(row.source_line).to eq(5)
        end

      end

    end


    describe 'table row output' do

      it 'can be remade from its own output' do
        source = ['| value1 | value2 |']
        source = source.join("\n")
        row = clazz.new(source)

        row_output = row.to_s
        remade_row_output = clazz.new(row_output).to_s

        expect(remade_row_output).to eq(row_output)
      end

    end

  end

end
