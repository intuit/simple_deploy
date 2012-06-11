require 'trollop'

module SimpleDeploy
  module CLI
    def self.start
      @opts = Trollop::options do
        banner <<-EOS
deploy and manage stacks
EOS
        opt :help, "Display Help"
        opt :attributes, "CSV list of updates attributes", :type => :string
        opt :environment, "Set the target environment", :type => :string
        opt :name, "Stack name to manage", :type => :string
        opt :template, "Path to the template file", :type => :string
      end

      @cmd = ARGV.shift

      case @cmd
      when 'create', 'delete', 'deploy', 'destroy', 'instances',
           'status', 'attributes', 'instances', 'events', 'resources',
           'outputs', 'template'
        @stack = Stack.new :environment => @opts[:environment],
                           :name        => @opts[:name]
      end

      read_attributes

      case @cmd
      when 'create'
        @stack.create :attributes => attributes,
                      :template => @opts[:template]
        puts "#{@opts[:name]} created."
      when 'deploy'
        @stack.deploy :attributes => attributes
        puts "#{@opts[:name]} deployed."
      when 'list'
        s = StackLister.new @opts[:environment]
        puts s.all
      when 'delete', 'destroy'
        @stack.destroy
        puts "#{@opts[:name]} destroyed."
      when 'instances'
        @stack.instances.each { |s| puts s }
      when 'template'
        jj @stack.template
      when 'events', 'outputs', 'resources', 'status'
        puts (@stack.send @cmd.to_sym).to_yaml
      when 'attributes'
        @stack.attributes.each_pair { |k, v| puts "#{k}: #{v}" }
      end
    end

    def self.attributes
      attrs = []
      read_attributes.each do |attribs|
        a = attribs.split('=')
        attrs << { a.first => a.last }
      end
      attrs
    end

    def self.read_attributes
      @opts[:attributes].nil? ? [] :  @opts[:attributes].split(',')
    end                                         
  end
end
