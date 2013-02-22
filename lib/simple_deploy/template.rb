module SimpleDeploy
  class Template
    def initialize(args)
      @file = args[:file]
    end

    def parameters
      parsed_template_contents.fetch('Parameters', {}).keys
    end

    private

    def parsed_template_contents
      JSON.parse contents
    end

    def contents
      @contents ||= IO.read @file
    end
  end
end
