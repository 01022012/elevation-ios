class LocalStorageUtil

  def self.get(key)
    App::Persistence[key]
  end

  def self.set(key, value)
    App::Persistence[key] = value
  end

  def self.delete(key)
    App::Persistence.delete(key)
  end
end
