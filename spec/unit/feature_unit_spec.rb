require 'spec_helper'


describe 'Feature, Unit' do

  let(:clazz) { CukeModeler::Feature }
  let(:feature) { clazz.new }


  describe 'common behavior' do

    it_should_behave_like 'a modeled element'
    it_should_behave_like 'a named element'
    it_should_behave_like 'a described element'
    it_should_behave_like 'a tagged element'
    it_should_behave_like 'a sourced element'
    it_should_behave_like 'a raw element'

  end


  describe 'unique behavior' do

    it 'can be instantiated with the minimum viable Gherkin' do
      source = 'Feature:'

      expect { clazz.new(source) }.to_not raise_error
    end

    it 'provides a descriptive filename when being parsed from stand alone text' do
      source = 'bad feature text'

      expect { clazz.new(source) }.to raise_error(/'cuke_modeler_stand_alone_feature\.feature'/)
    end

    it 'will complain about unknown element types' do
      parsed_element = {'description' => '',
                        'elements' => [{'keyword' => 'Scenario', 'description' => ''},
                                       {'keyword' => 'New Type', 'description' => ''}]}

      expect { clazz.new(parsed_element) }.to raise_error(ArgumentError)
    end

    it 'trims whitespace from its source description' do
      source = ['Feature:',
                '  ',
                '        description line 1',
                '',
                '   description line 2',
                '     description line 3               ',
                '',
                '',
                '',
                '  Scenario:']
      source = source.join("\n")

      feature = clazz.new(source)
      description = feature.description.split("\n")

      expect(description).to eq(['     description line 1',
                                 '',
                                 'description line 2',
                                 '  description line 3'])
    end

    it 'has a background' do
      feature.should respond_to(:background)
    end

    it 'can change its background' do
      expect(feature).to respond_to(:background=)

      feature.background = :some_background
      feature.background.should == :some_background
      feature.background = :some_other_background
      feature.background.should == :some_other_background
    end

    it 'knows whether or not it presently has a background - has_background?' do
      feature.background = :a_background
      feature.has_background?.should be_true
      feature.background = nil
      feature.has_background?.should be_false
    end

    it 'has tests' do
      feature.should respond_to(:tests)
    end

    it 'can change its tests' do
      expect(feature).to respond_to(:tests=)

      feature.tests = :some_tests
      feature.tests.should == :some_tests
      feature.tests = :some_other_tests
      feature.tests.should == :some_other_tests
    end

    it 'can selectively access its scenarios' do
      expect(feature).to respond_to(:scenarios)
    end

    it 'can selectively access its outlines' do
      expect(feature).to respond_to(:outlines)
    end

    it 'finds no scenarios or outlines when it has no tests' do
      feature.tests = []

      expect(feature.scenarios).to be_empty
      expect(feature.outlines).to be_empty
    end

    it 'contains a background, tests, and tags' do
      tags = [:tag_1, :tagt_2]
      tests = [:test_1, :test_2]
      background = :a_background
      everything = [background] + tests + tags

      feature.background = background
      feature.tests = tests
      feature.tags = tags

      expect(feature.children).to match_array(everything)
    end

    it 'contains a background only if one is present' do
      tests = [:test_1, :test_2]
      background = nil
      everything = tests

      feature.background = background
      feature.tests = tests

      feature.children.should =~ everything
    end


    describe 'model population' do

      context 'from source text' do

        context 'a filled feature' do

          let(:source_text) { "Feature: Feature name

                               Feature description.

                             Some more.
                                 Even more." }
          let(:feature) { clazz.new(source_text) }


          it "models the feature's name" do
            expect(feature.name).to eq('Feature name')
          end

          it "models the feature's description" do
            description = feature.description.split("\n")

            expect(description).to eq(['  Feature description.',
                                       '',
                                       'Some more.',
                                       '    Even more.'])
          end

        end

        context 'an empty feature' do

          let(:source_text) { 'Feature:' }
          let(:feature) { clazz.new(source_text) }

          it "models the feature's name" do
            expect(feature.name).to eq('')
          end

          it "models the feature's description" do
            expect(feature.description).to eq('')
          end

        end

      end

    end


    context 'from abstract instantiation' do

      let(:feature) { clazz.new }


      it 'starts with no background' do
        expect(feature.background).to be_nil
      end

      it 'starts with no tests' do
        expect(feature.tests).to eq([])
      end

    end


    describe 'feature output' do

      it 'is a String' do
        feature.to_s.should be_a(String)
      end


      context 'from source text' do

        it 'can output an empty feature' do
          source = ['Feature:']
          source = source.join("\n")
          feature = clazz.new(source)

          feature_output = feature.to_s.split("\n")

          expect(feature_output).to eq(['Feature:'])
        end

        it 'can output a feature that has a name' do
          source = ['Feature: test feature']
          source = source.join("\n")
          feature = clazz.new(source)

          feature_output = feature.to_s.split("\n")

          expect(feature_output).to eq(['Feature: test feature'])
        end

        it 'can output a feature that has a description' do
          source = ['Feature:',
                    'Some description.',
                    'Some more description.']
          source = source.join("\n")
          feature = clazz.new(source)

          feature_output = feature.to_s.split("\n")

          expect(feature_output).to eq(['Feature:',
                                        '',
                                        'Some description.',
                                        'Some more description.'])
        end

      end


      context 'from abstract instantiation' do

        let(:feature) { clazz.new }


        it 'can output an empty feature' do
          expect { feature.to_s }.to_not raise_error
        end

        it 'can output a feature that has only a name' do
          feature.name = 'a name'

          expect { feature.to_s }.to_not raise_error
        end

        it 'can output a feature that has only a description' do
          feature.description = 'a description'

          expect { feature.to_s }.to_not raise_error
        end

      end

    end

  end

end
