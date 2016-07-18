module CukeModeler

  # A class modeling a Cucumber Scenario.

  class Scenario < ModelElement

    include Parsed
    include Named
    include Described
    include Stepped
    include Sourceable
    include Taggable


    # Creates a new Scenario object and, if *source* is provided, populates the
    # object.
    def initialize(source_text = nil)
      @name = ''
      @description = ''
      @steps = []
      @tags = []

      super(source_text)

      if source_text
        parsed_scenario_data = parse_source(source_text)
        populate_scenario(self, parsed_scenario_data)
      end
    end

    # Returns true if the two elements have equivalent steps and false otherwise.
    def ==(other_element)
      return false unless other_element.respond_to?(:steps)

      steps == other_element.steps
    end

    # Returns the model objects that belong to this model.
    def children
      steps + tags
    end

    # Returns gherkin representation of the scenario.
    def to_s
      text = ''

      text << tag_output_string + "\n" unless tags.empty?
      text << "Scenario:#{name_output_string}"
      text << "\n" + description_output_string unless description.empty?
      text << "\n" unless steps.empty? || description.empty?
      text << "\n" + steps_output_string unless steps.empty?

      text
    end


    private


    def parse_source(source_text)
      base_file_string = "Feature: Fake feature to parse\n"
      source_text = base_file_string + source_text

      parsed_file = Parsing::parse_text(source_text, 'cuke_modeler_stand_alone_scenario.feature')

      parsed_file.first['elements'].first
    end

  end
end
