module SimpleDeploy
  class ArtifactLister

    def list
      Heirloom::Heirloom.list.keys
    end

    def all(args)
      artifacts = Heirloom::Heirloom.list
      artifacts[args[:class]]
    end

    def summary
      list 
    end

  end
end
