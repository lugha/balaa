from arabic_processing_cog.tokenization import ArabicTokenizer as arabic_tokenizer
from arabic_processing_cog.stemming import Light10stemmer as arabic_processing_cog_stemmer

string = 'مكتبة لمعالجة الكلمات العربية  وتجذيعها'
for token in arabic_tokenizer.tokenize(string):
    stem_word = arabic_processing_cog_stemmer.stem_token(token)
    print(stem_word)
