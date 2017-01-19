module Cli::Util
  struct Var(T)
    @var : T?

    def var
      @var
    end

    def var=(var)
      @var = var
    end
  end
end
