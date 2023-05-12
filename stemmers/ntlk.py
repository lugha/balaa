from nltk.stem.isri import ISRIStemmer

isri_stemmer = ISRIStemmer()
stem_word = isri_stemmer.stem(u"~A")
print(stem_word)
