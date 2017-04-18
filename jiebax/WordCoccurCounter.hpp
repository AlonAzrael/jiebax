#ifndef JIEBAX_WORD_COOCCUR_COUNTER_H
#define JIEBAX_WORD_COOCCUR_COUNTER_H

#include "limonp/StringUtil.hpp"

namespace cppjieba {
    using namespace limonp;
    using namespace std;

    class WordCoccurCounter
    {

    private:
        typedef std::vector<string> DocWords;

    public:
        WordCoccurCounter(){
            // just create obj
        };
        ~WordCoccurCounter(){};

        // fit some corpus, each time called will update co-occurrence matrix

        void AddDocWords(const vector<string>& doc_words){
        // count for word , not use window, since sentence are not big after psseg filtering.

        }

        void AddDocStringBatch(const vector<string>& doc_string_vector){
            
        }

        /* data */
    };

}



#endif




