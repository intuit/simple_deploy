module SimpleDeploy
  class ArtifactReader

    def self.list
      Heirloom::Heirloom.list.keys
    end

    def self.list_versions(artifact)
      Heirloom::Heirloom.list[artifact].keys
    end

    def self.info(args)
      Heirloom::Heirloom.info(args)
    end

  end
end
