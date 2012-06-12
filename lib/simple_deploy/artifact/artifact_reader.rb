require 'heirloom'

module SimpleDeploy
  class ArtifactReader

    def show(id)
      Heirloom::Heirloom.info :show => id
    end

  end
end
