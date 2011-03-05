#
# This adds transparent file content encryption/decryption
# on top of SimpleFileStore
#
# TODO: Implement an easy way to select the encryptor/decryptor.
#

module SecureFileStore

  private

  def pull(f)
    raw = f.read
    self.content = App.decrypt(raw) || raw
  end

  def push(f)
    f.write(App.encrypt(content))
  end

end
