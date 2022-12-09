from bidict import bidict

class Vocab:
    vocab = bidict()

    @staticmethod
    def get_word_from_id(id):
        if id in Vocab.vocab.inverse:
            return Vocab.vocab.inverse[id]
        else:
            return None

    @staticmethod
    def get_id_from_word(word):
        if word in Vocab.vocab:
            return Vocab.vocab[word]
        else:
            return None

    @staticmethod
    def add_word_to_vocab(word):
        if word in Vocab.vocab:
            return Vocab.vocab[word]
        else:
            newid = len(Vocab.vocab)
            Vocab.vocab[word] = newid
            return newid
