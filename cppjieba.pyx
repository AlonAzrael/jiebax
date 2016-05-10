#cython.wraparound=False
#cython.boundscheck=False

# from cppjieba cimport Jieba


from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.pair cimport pair
from libcpp.set cimport set as cppset

from cython.operator cimport dereference as deref, preincrement as inc


# declare cpp class from cpp source file
cdef extern from "Jieba.hpp" namespace "cppjieba":
    cdef cppclass Jieba:
        # Rectangle(int, int, int, int) except +
        Jieba(const string& , const string& , const string& ) except +
        # int x0, y0, x1, y1 # variable
        void Cut(const string& , vector[string]& , bint ) except +
        bint Tag(const string& , vector[pair[string, string] ]& ) except +
        bint TagNAV(const string& , vector[pair[string, string] ]& ) except +
        bint TagFilter(const string& src, vector[pair[string, string] ]& res, vector[string]& res_no_pair, vector[string]& ifin_list, vector[string]& startswith_list, int return_pair) except +


cdef extern from "TextRankExtractor.hpp" namespace "cppjieba":
    cdef cppclass TextRankExtractor:
        TextRankExtractor(const Jieba&, const string& ) except +
        void Extract(const string& , vector[pair[string, double] ]& , int ) except +
        void ExtractByWords(const vector[string]& words, vector[pair[string, double]]& keywords, int topN, int span, int rankTime) except +



cdef class JiebaX:
    
    # hold a C++ instance which we're wrapping
    cdef Jieba *thisptr
    # cdef Jieba& thisref
    
    def __cinit__(self, string dict_path = "./dict.txt", string model_path="./hmm_model.utf8", string user_dict_path=""):
        self.thisptr = new Jieba(dict_path, model_path, user_dict_path)
        # self.thisref = deref(self.thisptr)
    def __dealloc__(self):
        del self.thisptr

    """
    just return vector[...], since they can be interpreted as list and other stuff
    """

    # methods borrow from cppjieba

    def cut(self, string text):
        cdef vector[string] words_vector
        self.thisptr.Cut(text, words_vector, 1)
        # cdef list words = words_vector
        
        return words_vector

    def posseg(self, string text):
        cdef vector[pair[string, string]] words_pos_vector
        self.thisptr.Tag(text, words_pos_vector)

        return words_pos_vector

    def posseg_nav(self, string text, return_pair=False):
        cdef vector[pair[string, string]] words_pos_vector
        self.thisptr.TagNAV(text, words_pos_vector)

        if return_pair:
            return words_pos_vector

        # no pair
        cdef vector[pair[string, string]].iterator words_pos_vector_iter = words_pos_vector.begin()
        cdef vector[string] words
        cdef pair[string, string] temp_pair
        
        # cdef int counter = 0
        while words_pos_vector_iter != words_pos_vector.end():
            temp_pair = deref(words_pos_vector_iter)

            words.push_back(temp_pair.first)
            inc(words_pos_vector_iter)
            # counter += 1

        # print counter

        return words

    def posseg_filter(self, string text, set ifin_set=set(), list startswith_list=list(), return_pair=False):
        cdef vector[pair[string, string]] words_pos_vector
        cdef vector[string] words_vector
        
        cdef vector[string] ifin_list = list(ifin_set)

        cdef int return_pair_int
        if return_pair:
            return_pair_int = 1
        else:
            return_pair_int = 0

        # print ifin_list
        # print startswith_list
        self.thisptr.TagFilter(text, words_pos_vector, words_vector, ifin_list, startswith_list, return_pair_int)

        if return_pair:
            return words_pos_vector
        else:
            return words_vector

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

        if return_pair:
            for word, tag in self.posseg(text):
                if tag.startswith("n") or tag == "a" or tag == "v":
                    return_list.append((word, tag))
        else:
            for word, tag in self.posseg(text):
                if tag.startswith("n") or tag == "a" or tag == "v":
                    return_list.append(word)

        return return_list

        # return self._posseg_nav(text, return_pair)


cdef class JiebaXTextRank:

    cdef TextRankExtractor *thisptr

    def __cinit__(self, JiebaX jiebax, string stop_words_filepath="./stop_words.utf8"):
        self.thisptr = new TextRankExtractor(deref(jiebax.thisptr), stop_words_filepath)
    def __dealloc__(self):
        del self.thisptr

    def extract(self, string text, int max_words=50):
        cdef vector[pair[string, double]] keyword_weight_list
        self.thisptr.Extract(text, keyword_weight_list, max_words)

        return keyword_weight_list

    def extract_by_words(self, list words, int max_words=50, int n_span=5, int max_rank_epoch=10):
        cdef vector[string] words_vector = words
        cdef vector[pair[string, double]] keyword_weight_list

        if len(words) < 3:
            return [(word, 1.0) for word in words ]

        self.thisptr.ExtractByWords(words_vector, keyword_weight_list, max_words, n_span, max_rank_epoch)

        return keyword_weight_list









