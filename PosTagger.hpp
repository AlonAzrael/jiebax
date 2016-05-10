#ifndef CPPJIEBA_POS_TAGGING_H
#define CPPJIEBA_POS_TAGGING_H

#include "MixSegment.hpp"
#include "limonp/StringUtil.hpp"
#include "DictTrie.hpp"

// aaronyin-code-start
#include <set>
#include <unordered_set>
// aaronyin-code-end

namespace cppjieba {
using namespace limonp;

static const char* const POS_M = "m";
static const char* const POS_ENG = "eng";
static const char* const POS_X = "x";
static const string TAG_N = "n";
static const string TAG_A = "a";
static const string TAG_V = "v";

class PosTagger {
 public:
  PosTagger(const string& dictPath,
    const string& hmmFilePath,
    const string& userDictPath = "")
    : segment_(dictPath, hmmFilePath, userDictPath) {
  }
  PosTagger(const DictTrie* dictTrie, const HMMModel* model) 
    : segment_(dictTrie, model) {
  }
  ~PosTagger() {
  }

  bool Tag(const string& src, vector<pair<string, string> >& res) const {
    vector<string> CutRes;
    segment_.Cut(src, CutRes);

    const DictUnit *tmp = NULL;
    RuneStrArray runes;
    const DictTrie * dict = segment_.GetDictTrie();
    assert(dict != NULL);
    for (vector<string>::iterator itr = CutRes.begin(); itr != CutRes.end(); ++itr) {
      if (!DecodeRunesInString(*itr, runes)) {
        XLOG(ERROR) << "Decode failed.";
        return false;
      }
      tmp = dict->Find(runes.begin(), runes.end());
      if (tmp == NULL || tmp->tag.empty()) {
        res.push_back(make_pair(*itr, SpecialRule(runes)));
      } else {
        res.push_back(make_pair(*itr, tmp->tag));
      }
    }
    return !res.empty();
  }
  
  // aaronyin-code-start
  bool TagNAV(const string& src, vector<pair<string, string> >& res) const {
    vector<string> CutRes;
    segment_.Cut(src, CutRes);

    string tag_to_check;
    // set<string> myset;
    // set<string>::iterator it;

    const DictUnit *tmp = NULL;
    RuneStrArray runes;
    const DictTrie * dict = segment_.GetDictTrie();
    assert(dict != NULL);
    for (vector<string>::iterator itr = CutRes.begin(); itr != CutRes.end(); ++itr) {
      if (!DecodeRunesInString(*itr, runes)) {
        XLOG(ERROR) << "Decode failed.";
        return false;
      }
      tmp = dict->Find(runes.begin(), runes.end());
      if (tmp == NULL || tmp->tag.empty()) {
        // just ignore x for now
        // res.push_back(make_pair(*itr, SpecialRule(runes)));
      } else {
        // check for conditions
        tag_to_check = tmp->tag;
        if (tag_to_check.substr(0, 1) == TAG_N || tag_to_check == TAG_V || tag_to_check == TAG_A)
        {
          res.push_back(make_pair(*itr, tag_to_check));
        }
      }
    }
    return !res.empty();
  }
  // aaronyin-code-end

  // aaronyin-code-start
  bool TagFilter(const string& src, vector<pair<string, string> >& res, vector<string>& res_no_pair, vector<string>& ifin_list, vector<string>& startswith_list, int return_pair = 0 ) const {
    vector<string> CutRes;
    segment_.Cut(src, CutRes);

    string tag_to_check;
    string tag_head;
    bool append_flag = false;

    unordered_set<string> ifin_hashset;
    for (vector<string>::iterator i = ifin_list.begin(); i != ifin_list.end(); ++i)
    {
      ifin_hashset.insert(*i);
    }

    const DictUnit *tmp = NULL;
    RuneStrArray runes;
    const DictTrie * dict = segment_.GetDictTrie();
    assert(dict != NULL);
    for (vector<string>::iterator itr = CutRes.begin(); itr != CutRes.end(); ++itr) {
      if (!DecodeRunesInString(*itr, runes)) {
        XLOG(ERROR) << "Decode failed.";
        return false;
      }
      tmp = dict->Find(runes.begin(), runes.end());
      if (tmp == NULL || tmp->tag.empty()) {
        // just ignore x for now
        // res.push_back(make_pair(*itr, SpecialRule(runes)));
      } else {
        // check for conditions
        tag_to_check = tmp->tag;
        append_flag = false;

        // if in
        if (ifin_hashset.find(tag_to_check) != ifin_hashset.end())
        {
          append_flag = true;
        } 
        // startswith
        else {
          tag_head = tag_to_check.substr(0, 1);
          for (vector<string>::iterator i = startswith_list.begin(); i != startswith_list.end(); ++i)
          {
            if (tag_head == *i){
              append_flag = true;
              break;
            }
          }
        }

        // append ?
        if (append_flag)
        {
          if (return_pair > 0)
          {
            res.push_back(make_pair(*itr, tag_to_check));
          } else {
            res_no_pair.push_back(*itr);
          }
        }

      }
    }
    return !res.empty();
  }
  // aaronyin-code-end

 private:
  const char* SpecialRule(const RuneStrArray& unicode) const {
    size_t m = 0;
    size_t eng = 0;
    for (size_t i = 0; i < unicode.size() && eng < unicode.size() / 2; i++) {
      if (unicode[i].rune < 0x80) {
        eng ++;
        if ('0' <= unicode[i].rune && unicode[i].rune <= '9') {
          m++;
        }
      }
    }
    // ascii char is not found
    if (eng == 0) {
      return POS_X;
    }
    // all the ascii is number char
    if (m == eng) {
      return POS_M;
    }
    // the ascii chars contain english letter
    return POS_ENG;
  }

  MixSegment segment_;
}; // class PosTagger

} // namespace cppjieba

#endif
