module CukeModeler

  # A class modeling a feature's background.

  class Background < Model

    include Parsing
    include Parsed
    include Named
    include Described
    include Stepped
    include Sourceable


    # The background's keyword
    attr_accessor :keyword


    # Creates a new Background object and, if *source_text* is provided, populates
    # the object.
    def initialize(source_text = nil)
      @steps = []

      super(source_text)

      if source_text
        parsed_background_data = parse_source(source_text)
        populate_background(self, parsed_background_data)
      end
    end

    # Returns *true* if the two models have equivalent steps and *false* otherwise.
    def ==(other_model)
      return false unless other_model.respond_to?(:steps)

      steps == other_model.steps
    end

    # Returns the model objects that belong to this model.
    def children
      steps
    end

    # Returns a string representation of this model. For a background model,
    # this will be Gherkin text that is equivalent to the background being modeled.
    def to_s
      text = ''

      text << "#{@keyword}:#{name_output_string}"
      text << "\n" + description_output_string unless (description.nil? || description.empty?)
      text << "\n" unless (steps.empty? || description.nil? || description.empty?)
      text << "\n" + steps_output_string unless steps.empty?

      text
    end


    private


    def parse_source(source_text)
      base_file_string = "# language: #{Parsing.dialect}\n#{dialect_feature_keyword}: Fake feature to parse\n"
      source_text = base_file_string + source_text

      parsed_file = Parsing::parse_text(source_text, 'cuke_modeler_stand_alone_background.feature')

      parsed_file.first['elements'].first
    end

  end
end
