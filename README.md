

使用Cython对jieba分词进行优化。  
本质上是一个C++版本的jieba的Wrapper，同时加入了一些新功能。  
分词性能比原始的jieba要快16倍，POSTag分词比原始的jieba快100倍(因为原始的jieba要在使用python进行pos过滤，而JiebaX在C++代码里做过滤)。  


