#
# This adds transparent file content encryption/decryption
# on top of SimpleFileStore
#
# TODO: Implement an easy way to select the encryptor/decryptor.
#

class SecureFileStore < ScalableFileStore

  private

  def pull(f)
    raw = f.read
    self.file = App.decrypt(raw) || raw
  end

  def push(f)
    f.write(App.encrypt(file))
  end

end
