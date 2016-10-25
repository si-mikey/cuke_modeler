require "#{File.dirname(__FILE__)}/../spec_helper"


describe 'Scenario, Integration' do

  let(:clazz) { CukeModeler::Scenario }


  describe 'common behavior' do

    it_should_behave_like 'a model, integration'

  end

  describe 'unique behavior' do

    it 'can be instantiated with the minimum viable Gherkin' do
      source = 'Scenario:'

      expect { clazz.new(source) }.to_not raise_error
    end

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = "bad scenario text \n Scenario:\n And a step\n @foo "

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_scenario\.feature'/)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin4 => true do
      scenario = clazz.new("@tag\nScenario: test scenario\ndescription\n* a step")
      data = scenario.parsing_data

      expect(data.keys).to match_array([:type, :tags, :location, :keyword, :name, :steps, :description])
      expect(data[:type]).to eq(:Scenario)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin3 => true do
      scenario = clazz.new("@tag\nScenario: test scenario\ndescription\n* a step")
      data = scenario.parsing_data

      expect(data.keys).to match_array([:type, :tags, :location, :keyword, :name, :steps, :description])
      expect(data[:type]).to eq(:Scenario)
    end

    it 'stores the original data generated by the parsing adapter', :gherkin2 => true do
      scenario = clazz.new("@tag\nScenario: test scenario\ndescription\n* a step")
      data = scenario.parsing_data

      expect(data.keys).to match_array(['keyword', 'name', 'line', 'description', 'id', 'type', 'steps', 'tags'])
      expect(data['keyword']).to eq('Scenario')
    end

    it 'properly sets its child models' do
      source = ['@a_tag',
                'Scenario: Test scenario',
                '  * a step']
      source = source.join("\n")

      scenario = clazz.new(source)
      step = scenario.steps.first
      tag = scenario.tags.first

      expect(step.parent_model).to equal(scenario)
      expect(tag.parent_model).to equal(scenario)
    end

    it 'trims whitespace from its source description' do
      source = ['Scenario:',
                '  ',
                '        description line 1',
                '',
                '   description line 2',
                '     description line 3               ',
                '',
                '',
                '',
                '  * a step']
      source = source.join("\n")

      scenario = clazz.new(source)
      description = scenario.description.split("\n", -1)

      expect(description).to eq(['     description line 1',
                                 '',
                                 'description line 2',
                                 '  description line 3'])
    end


    describe 'getting ancestors' do

      before(:each) do
        source = ['Feature: Test feature',
                  '',
                  '  Scenario: Test test',
                  '    * a step']
        source = source.join("\n")

        file_path = "#{@default_file_directory}/scenario_test_file.feature"
        File.open(file_path, 'w') { |file| file.write(source) }
      end

      let(:directory) { CukeModeler::Directory.new(@default_file_directory) }
      let(:scenario) { directory.feature_files.first.feature.tests.first }


      it 'can get its directory' do
        ancestor = scenario.get_ancestor(:directory)

        expect(ancestor).to equal(directory)
      end

      it 'can get its feature file' do
        ancestor = scenario.get_ancestor(:feature_file)

        expect(ancestor).to equal(directory.feature_files.first)
      end

      it 'can get its feature' do
        ancestor = scenario.get_ancestor(:feature)

        expect(ancestor).to equal(directory.feature_files.first.feature)
      end

      it 'returns nil if it does not have the requested type of ancestor' do
        ancestor = scenario.get_ancestor(:test)

        expect(ancestor).to be_nil
      end


      describe 'model population' do

        context 'from source text' do

          it "models the scenario's source line" do
            source_text = "Feature:

                           Scenario: foo
                             * step"
            scenario = CukeModeler::Feature.new(source_text).tests.first

            expect(scenario.source_line).to eq(3)
          end


          context 'a filled scenario' do

            let(:source_text) { '@tag1 @tag2 @tag3
                                 Scenario: Scenario name

                                     Scenario description.

                                   Some more.
                                       Even more.

                                 * a step
                                 * another step' }
            let(:scenario) { clazz.new(source_text) }


            it "models the scenario's name" do
              expect(scenario.name).to eq('Scenario name')
            end

            it "models the scenario's description" do
              description = scenario.description.split("\n", -1)

              expect(description).to eq(['  Scenario description.',
                                         '',
                                         'Some more.',
                                         '    Even more.'])
            end

            it "models the scenario's steps" do
              step_names = scenario.steps.collect { |step| step.text }

              expect(step_names).to eq(['a step', 'another step'])
            end

            it "models the scenario's tags" do
              tag_names = scenario.tags.collect { |tag| tag.name }

              expect(tag_names).to eq(['@tag1', '@tag2', '@tag3'])
            end

          end

          context 'an empty scenario' do

            let(:source_text) { 'Scenario:' }
            let(:scenario) { clazz.new(source_text) }


            it "models the scenario's name" do
              expect(scenario.name).to eq('')
            end

            it "models the scenario's description" do
              expect(scenario.description).to eq('')
            end

            it "models the scenario's steps" do
              expect(scenario.steps).to eq([])
            end

            it "models the scenario's tags" do
              expect(scenario.tags).to eq([])
            end

          end

        end

      end


      describe 'comparison' do

        it 'is equal to a background with the same steps' do
          source = "Scenario:
                      * step 1
                      * step 2"
          scenario = clazz.new(source)

          source = "Background:
                      * step 1
                      * step 2"
          background_1 = CukeModeler::Background.new(source)

          source = "Background:
                      * step 2
                      * step 1"
          background_2 = CukeModeler::Background.new(source)


          expect(scenario).to eq(background_1)
          expect(scenario).to_not eq(background_2)
        end

        it 'is equal to a scenario with the same steps' do
          source = "Scenario:
                      * step 1
                      * step 2"
          scenario_1 = clazz.new(source)

          source = "Scenario:
                      * step 1
                      * step 2"
          scenario_2 = clazz.new(source)

          source = "Scenario:
                      * step 2
                      * step 1"
          scenario_3 = clazz.new(source)


          expect(scenario_1).to eq(scenario_2)
          expect(scenario_1).to_not eq(scenario_3)
        end

        it 'is equal to an outline with the same steps' do
          source = "Scenario:
                      * step 1
                      * step 2"
          scenario = clazz.new(source)

          source = "Scenario Outline:
                      * step 1
                      * step 2
                    Examples:
                      | param |
                      | value |"
          outline_1 = CukeModeler::Outline.new(source)

          source = "Scenario Outline:
                      * step 2
                      * step 1
                    Examples:
                      | param |
                      | value |"
          outline_2 = CukeModeler::Outline.new(source)


          expect(scenario).to eq(outline_1)
          expect(scenario).to_not eq(outline_2)
        end

      end


      describe 'scenario output' do

        it 'can be remade from its own output' do
          source = ['@tag1 @tag2 @tag3',
                    'Scenario: A scenario with everything it could have',
                    '',
                    'Including a description',
                    'and then some.',
                    '',
                    '  * a step',
                    '    | value |',
                    '  * another step',
                    '    """',
                    '    some string',
                    '    """']
          source = source.join("\n")
          scenario = clazz.new(source)

          scenario_output = scenario.to_s
          remade_scenario_output = clazz.new(scenario_output).to_s

          expect(remade_scenario_output).to eq(scenario_output)
        end


        context 'from source text' do

          it 'can output an empty scenario' do
            source = ['Scenario:']
            source = source.join("\n")
            scenario = clazz.new(source)

            scenario_output = scenario.to_s.split("\n", -1)

            expect(scenario_output).to eq(['Scenario:'])
          end

          it 'can output a scenario that has a name' do
            source = ['Scenario: test scenario']
            source = source.join("\n")
            scenario = clazz.new(source)

            scenario_output = scenario.to_s.split("\n", -1)

            expect(scenario_output).to eq(['Scenario: test scenario'])
          end

          it 'can output a scenario that has a description' do
            source = ['Scenario:',
                      'Some description.',
                      'Some more description.']
            source = source.join("\n")
            scenario = clazz.new(source)

            scenario_output = scenario.to_s.split("\n", -1)

            expect(scenario_output).to eq(['Scenario:',
                                           '',
                                           'Some description.',
                                           'Some more description.'])
          end

          it 'can output a scenario that has steps' do
            source = ['Scenario:',
                      '* a step',
                      '|value|',
                      '* another step',
                      '"""',
                      'some string',
                      '"""']
            source = source.join("\n")
            scenario = clazz.new(source)

            scenario_output = scenario.to_s.split("\n", -1)

            expect(scenario_output).to eq(['Scenario:',
                                           '  * a step',
                                           '    | value |',
                                           '  * another step',
                                           '    """',
                                           '    some string',
                                           '    """'])
          end

          it 'can output a scenario that has tags' do
            source = ['@tag1 @tag2',
                      '@tag3',
                      'Scenario:']
            source = source.join("\n")
            scenario = clazz.new(source)

            scenario_output = scenario.to_s.split("\n", -1)

            expect(scenario_output).to eq(['@tag1 @tag2 @tag3',
                                           'Scenario:'])
          end

          it 'can output a scenario that has everything' do
            source = ['@tag1 @tag2 @tag3',
                      'Scenario: A scenario with everything it could have',
                      'Including a description',
                      'and then some.',
                      '* a step',
                      '|value|',
                      '* another step',
                      '"""',
                      'some string',
                      '"""']
            source = source.join("\n")
            scenario = clazz.new(source)

            scenario_output = scenario.to_s.split("\n", -1)

            expect(scenario_output).to eq(['@tag1 @tag2 @tag3',
                                           'Scenario: A scenario with everything it could have',
                                           '',
                                           'Including a description',
                                           'and then some.',
                                           '',
                                           '  * a step',
                                           '    | value |',
                                           '  * another step',
                                           '    """',
                                           '    some string',
                                           '    """'])
          end

        end


        context 'from abstract instantiation' do

          let(:scenario) { clazz.new }


          it 'can output a scenario that has only tags' do
            scenario.tags = [CukeModeler::Tag.new]

            expect { scenario.to_s }.to_not raise_error
          end

          it 'can output a scenario that has only steps' do
            scenario.steps = [CukeModeler::Step.new]

            expect { scenario.to_s }.to_not raise_error
          end

        end

      end

    end

  end

end


