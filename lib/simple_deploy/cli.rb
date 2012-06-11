module SimpleDeploy
  module CLI
    def self.start
      puts SimpleDeploy::ArtifactReader.list
      puts SimpleDeploy::ArtifactReader.list_versions('cookbooks')
      puts SimpleDeploy::ArtifactReader.info :class => 'cookbooks',
                                             :sha => '0ddc61c8c99023ec9920f052e97e7e9d469eb42d'
      puts SimpleDeploy::StackLister.list
    end
  end
end

