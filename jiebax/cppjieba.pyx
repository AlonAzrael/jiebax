#cython.wraparound=False
#cython.boundscheck=False

# from cppjieba cimport Jieba


from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.pair cimport pair
from libcpp.set cimport set as cppset

from cython.operator cimport dereference as deref, preincrement as inc

from cython.parallel cimport *

import os
import site

SITEPKGS_PATH = site.getsitepackages()[0]
DATA_PATH_DICT = dict(dict_path="jieba.dict.better.txt", model_path="hmm_model.utf8", stop_words_filepath="stop_words.utf8")


for name, fpath in DATA_PATH_DICT.items():
    temp = os.path.join(SITEPKGS_PATH, "jiebax", fpath)
    # print temp
    if os.path.isfile(temp):
        DATA_PATH_DICT[name] = temp
    else:
        DATA_PATH_DICT[name] = os.path.join("./jiebax", fpath)


DICT_PATH = DATA_PATH_DICT["dict_path"]
MODEL_PATH = DATA_PATH_DICT["model_path"]
STOPWORDS_PATH = DATA_PATH_DICT["stop_words_filepath"]


from pkg_resources import resource_string







# declare cpp class from cpp source file
cdef extern from "Jieba.hpp" namespace "cppjieba":
    cdef cppclass Jieba:
        # Rectangle(int, int, int, int) except +
        Jieba(const string& , const string& , const string& ) except +
        # int x0, y0, x1, y1 # variable
        void Cut(const string& , vector[string]& , bint ) nogil except +
        bint Tag(const string& , vector[pair[string, string] ]& ) except +
        bint TagNAV(const string& , vector[pair[string, string] ]& ) except +
        bint TagFilter(const string& src, vector[pair[string, string] ]& res, vector[string]& res_no_pair, vector[string]& ifin_list, vector[string]& startswith_list, int return_pair) except +


cdef extern from "TextRankExtractor.hpp" namespace "cppjieba":
    cdef cppclass TextRankExtractor:
        TextRankExtractor(const Jieba&, const string& ) except +
        void Extract(const string& , vector[pair[string, double] ]& , int ) except +
        void ExtractByWords(const vector[string]& words, vector[pair[string, double]]& keywords, int topN, int span, int rankTime) except +




# def jiebax_preprocessor(func):

#     def func_wrapper(*args, **kwargs):
#         if type(text) == unicode:
#             text = text.encode("utf-8")

#         return text


cdef class JiebaX:
    
    # hold a C++ instance which we're wrapping
    cdef Jieba *thisptr
    # cdef Jieba& thisref
    cdef string dict_path, model_path, user_dict_path
    
    def __cinit__(self, dict_path=DICT_PATH, model_path=MODEL_PATH, user_dict_path=""):
        self.dict_path = dict_path.encode("utf-8")
        self.model_path = model_path.encode("utf-8")
        self.user_dict_path = user_dict_path.encode("utf-8")
        self.thisptr = new Jieba(self.dict_path, self.model_path, self.user_dict_path)
        # self.thisref = deref(self.thisptr)

    def __dealloc__(self):
        del self.thisptr

    """
    just return vector[...], since they can be interpreted as list and other stuff
    """

    # utils

    def convert_encode(self, text):
#         if type(text) == str:
        text = text.encode("utf-8")
        return text

    # methods from cppjieba

    def cut(self, text):
        text = self.convert_encode(text)

        cdef vector[string] words_vector
        self.thisptr.Cut(text, words_vector, 1)
        # cdef list words = words_vector

        cdef list words_unicode
        words_unicode = words_vector
        words_unicode = [word.decode("utf-8") for word in words_unicode]
        return words_unicode
    
    def encode_pairs(self, words_pos_vector):
        return [(x[0].decode("utf-8"),x[1].decode("utf-8")) for x in words_pos_vector]

    def posseg(self, text):
        text = self.convert_encode(text)

        cdef vector[pair[string, string]] words_pos_vector
        self.thisptr.Tag(text, words_pos_vector)
        # TODO: return pair
        return self.encode_pairs(words_pos_vector)

    def posseg_nav(self, text, int return_pair=0):
        text = self.convert_encode(text)

        cdef vector[pair[string, string]] words_pos_vector
        self.thisptr.TagNAV(text, words_pos_vector)

        if return_pair:
            return self.encode_pairs(words_pos_vector)

        # no pair
        cdef vector[pair[string, string]].iterator words_pos_vector_iter = words_pos_vector.begin()
        cdef list words = []
        cdef bytes s
        cdef pair[string, string] temp_pair
        
        # cdef int counter = 0
        while words_pos_vector_iter != words_pos_vector.end():
            temp_pair = deref(words_pos_vector_iter)
            s = temp_pair.first
            words.append(s.decode("utf-8"))
            inc(words_pos_vector_iter)
            # counter += 1

        # print counter

        return words

    def posseg_filter(self, text, set ifin_set=set(), list startswith_list=list(), int return_pair=0):
        text = self.convert_encode(text)
        
        cdef vector[pair[string, string]] words_pos_vector
        cdef vector[string] words_vector        
        cdef vector[string] ifin_list = list(ifin_set)

        self.thisptr.TagFilter(text, words_pos_vector, words_vector, ifin_list, startswith_list, return_pair)
        cdef list words
        if return_pair:
            return self.encode_pairs(words_pos_vector)
        else:
            words = words_vector
            return [w.decode("utf-8") for w in words]

    def cut_multi(self, text_list, int n_jobs=2):
        text_list = [self.convert_encode(t) for t in text_list]
        cdef:
            vector[string] text_vect = text_list
            vector[vector[string]] words_vector_job
            int i = 0
            Jieba *jbp = self.thisptr

        words_vector_job.resize(text_vect.size())

        # print "cut_multi n_jobs:", n_jobs
        with nogil, parallel(num_threads=n_jobs):
            for i in prange(
                text_vect.size(), 
            ):
                # jbp = new Jieba(self.dict_path, self.model_path, self.user_dict_path)
                jbp.Cut(
                    text_vect[i], 
                    words_vector_job[i], 
                    1
                )

        cdef list words_unicode_job = words_vector_job,  words_unicode
        words_unicode_job = [[word.decode("utf-8") for word in words_unicode] for words_unicode in words_unicode_job]
        
        return words_unicode_job

    # for backwards compability

    def cut_docs_multi(self, docs, pos_tags=[], n_threads=1):
        if n_threads < 2:
            doc_words_list = [self.posseg_nav(doc, return_pair=False) for doc in docs]
        else:
            raise Exception("no multithread implementation")

        return doc_words_list

    def cut_docs(self, *args, **kwargs):
        return self.cut_docs_multi(*args, n_threads=1, **kwargs)

    # utils 

    def remove_tags(self):
        cdef int x
        x = 1
        print "remove_tags", x

    # new added methods

    def _DEPRE_posseg_filter(self, string text, list startswith_list=[], set ifin_set=set(), return_pair=False):
        cdef string word
        
        # cdef string tag
        # cdef cppset[string] ifin_cppset = ifin_set
        # cdef cppset[string].iterator cppset_end = ifin_cppset.end()

        cdef str tag
        
        cdef list return_list = []
        cdef int append_flag = 0

        # print ifin_set

        for word, tag in self.posseg(text):
            append_flag = 0

            # if ifin_cppset.find(tag) != cppset_end:
            if tag in ifin_set:
                append_flag = 1
            
            else:
                for stag in startswith_list:
                    if tag.startswith(stag):
                        append_flag = 1
                        break

            if append_flag > 0:
                if return_pair:
                    return_list.append( (word, tag) )
                else:
                    return_list.append( word )

        return return_list

    def _DEPRE_posseg_nav(self, string text, return_pair=False):
        # using self._posseg_nav instead
        
        cdef string word
        cdef string tag
        cdef list return_list = []

        cdef string tag_a = "a"
        cdef string tag_v = "v"

        if return_pair:
            for word, tag in self.posseg(text):
                if tag.startswith("n") or tag == tag_a or tag == tag_v:
                    return_list.append((word, tag))
        else:
            for word, tag in self.posseg(text):
                if tag.startswith("n") or tag == tag_a or tag == tag_v:
                    return_list.append(word)

        return return_list

        # return self._posseg_nav(text, return_pair)


cdef class JiebaXTextRank:

    cdef TextRankExtractor *thisptr

    def __cinit__(self, JiebaX jiebax, stop_words_filepath=STOPWORDS_PATH):
        self.thisptr = new TextRankExtractor(deref(jiebax.thisptr), stop_words_filepath.encode("utf-8"))
    def __dealloc__(self):
        del self.thisptr

    def extract(self, text, int max_words=50):
        cdef vector[pair[string, double]] keyword_weight_list
        self.thisptr.Extract(text.encode("utf-8"), keyword_weight_list, max_words)

        return keyword_weight_list

    def extract_by_words(self, list words, int max_words=50, int n_span=5, int max_rank_epoch=10):
        cdef vector[string] words_vector = [w.encode("utf-8") for w in words]
        cdef vector[pair[string, double]] keyword_weight_list

        if len(words) < 3:
            return [(word, 1.0) for word in words ]

        self.thisptr.ExtractByWords(words_vector, keyword_weight_list, max_words, n_span, max_rank_epoch)

        return keyword_weight_list






