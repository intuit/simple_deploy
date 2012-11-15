module SimpleDeploy
  class Env

    def load(var)
      ENV.fetch var, nil
    end

  end
end
