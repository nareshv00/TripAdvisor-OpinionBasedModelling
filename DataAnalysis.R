#installing plyr to use rbind.fill
install.packages("plyr")
library(plyr)
#setting the path where we have all the text files of individual hotel reviews
setwd('E:/Data mining/project/OpinRankDatasetWithJudgments/hotels/data')

#Loading all the file folder inside the given into the vector file_list
file_list <- list.files( )

#making data set to null before running the for loop to avoid unnessary concatenation.
dataset=NULL;
##code for getting data and merging from the above path
#file_list is the master direcory
#file is the individual folders  inside the file_list
for(file in file_list)
{
  #setting the master directory as the primary directory, to do that we used file appended to the previous working directory
  #aim is to merge all the data files inside this directory
  #This directory has 10 sub folder which has all the files of the hotel reviews
  setwd(paste('E:/Data mining/project/OpinRankDatasetWithJudgments/hotels/data/',file,sep=""))
  #after setting the current directory , I am taking the file names in the individual folder into vecto indi_file_list
  indi_file_list <- list.files()
  #iterating through invidual folders and files
  for (file1 in indi_file_list){
    # if the merged dataset doesn't exist, create it
    if (!exists("dataset")){
      dataset <- read.delim(file1,header = F,sep="\t")
      dataset$HotelName=file1
      ifelse(dataset$HotelName=='',file,dataset$HotelName)
    }
    # if the merged dataset does exist, append to it
    if (exists("dataset")){
      temp_dataset <-read.delim(file1, header=F, sep="\t")
      ifelse(temp_dataset$HotelName=='',file,temp_dataset$HotelName)
      temp_dataset$HotelName=file1;
      dataset<-rbind.fill(dataset, temp_dataset)
      rm(temp_dataset)
    }
    
  }
}
#writing the CSV file to the respective path
write.csv(dataset,"ReviewsHotelName.csv")

# In the above way I am going to merge the Rating's of the individual hotels into one master CSV file
# Combining all the csv files in the data folder
# Below is the path where we have hotel rating CSV's.
setwd("E:/Data mining/project/OpinRankDatasetWithJudgments/hotels/data csv")
#Reading all the names of CSV's into csvList.
csvList=list.files();
#making data set to null before running the for loop to avoid unnessary concatenation.
dataset=NULL;

for (file in csvList){
  # if the merged dataset doesn't exist, create it
  if (!exists("dataset")){
    dataset <- read.csv(file)
  }
  # if the merged dataset does exist, append to it
  if (exists("dataset")){
    temp_dataset <-read.csv(file)
    ifelse(temp_dataset$HotelName=='',file,temp_dataset$HotelName)
    dataset<-rbind.fill(dataset, temp_dataset)
    rm(temp_dataset)
  }
  
}
#wrting the CSV file as the HotelData.csv
write.csv(dataset,file="Hoteldata.csv")


#reading the review hotel data set to add headers

ReviewsHotelName=read.csv("ReviewsHotelName.csv")
#done this step becasue column name of review date has column id values 
ReviewsHotelName$ReviewDate=NULL;
#renaming all the columns
colnames(ReviewsHotelName)=c("ReviewDate","ReviewTitle","FullReview","HotelName");
#writing the updated CSV
write.csv(ReviewsHotelName,file="ReviewsHotelName.csv")

#deleting all the documents which has no full reviews
#after doing this step we have a total of 212953 documents in our data set
ReviewsHotelName=subset(ReviewsHotelName,ReviewsHotelName$FullReview!='')
#Starting with preprocessing the data
#performing text analytics preprocessing steps, installing the required packages
install.packages('tm')
install.packages('SnowballC')
#loading the data sets using library function
library(tm)
library(SnowballC)
#creating the corpus , which is a collection of all the full reviews in the dataset
corpus=Corpus(VectorSource(ReviewsHotelName$FullReview))
#Making all the letters in the corpus to lowercase for processing string comparisions
corpus=tm_map(corpus,tolower)
#converting the corpus into plaitext document
corpus=tm_map(corpus,PlainTextDocument)
#Removing all the punctuations from the corpus
corpus=tm_map(corpus,removePunctuation)
#removing the numbers from corpus
corpus=tm_map(corpus,removeNumbers)

#removing the english and custom stop words
corpus=tm_map(corpus,removeWords,c('hotel','room','hotel','room','stay','quot','night',stopwords('en')))
#stemming the document to increase the frequency of repeated words.
corpus=tm_map(corpus,stemDocument)
#converting the corpus into document term matrix or sparse matrix
dtm=DocumentTermMatrix(corpus)

#removing less repeated words from document term matrix,keeping only words which 
#are repeated more than 10% of the times
SparseReviews=removeSparseTerms(dtm,0.99)


#converting sparse reviews to a data frame
SparseReviewsDF=as.data.frame(as.matrix(SparseReviews))
SparseReviewsDF$HotelName=ReviewsHotelName$HotelName;



#adding word clouds to create word clouds for all the hotel reviews data.
install.packages("wordcloud")
library(wordcloud)
?wordcloud

#word cloud of the the data which is repeated in atleast 10% of the data.
wordcloud(colnames(SparseReviewsDF[,1:1073]),colSums(SparseReviewsDF[,1:1073]),min.freq = 6,scale = c(4,0.5),colors = brewer.pal(9,'Set1'),random.color = TRUE)

#slecting the brewer, please run the below command to effectively selectthe 
display.brewer.all()


# As we know that hotel reviews will act sepeartely with hotel and the city I am creating a 
#dynamic function to create word clouds based on the input city and input hotel name
#we can connect a user interface to this 
City="delhi"
Hotel="ajanta"
#subsetting the data based on the City and Hotel names
IndividualHotelReviews=subset(SparseReviewsDF,grepl(City,HotelName)&grepl(Hotel,HotelName),drop = T);
#implementing wordcloud for this specific city and the specific hotel
#I have used two different color brewers for word cloud generation
wordcloud(colnames(IndividualHotelReviews[,1:1073]),colSums(IndividualHotelReviews[,1:1073]),min.freq = 1,scale = c(4,0.5),colors=brewer.pal(9, "Blues"),random.color = TRUE)

wordcloud(colnames(IndividualHotelReviews[,1:1073]),colSums(IndividualHotelReviews[,1:1073]),min.freq = 6,scale = c(4,0.5),colors = brewer.pal(8,'Set1'),random.color = TRUE)

#Working with review title ,as we found that it might be more useful than the
#actual review
#performing the same set of statements on this data.
#corpus
corpusReviewTitle=Corpus(VectorSource(ReviewsHotelName$ReviewTitle))
#lower
corpusReviewTitle=tm_map(corpusReviewTitle,tolower)
#plaitext
corpusReviewTitle=tm_map(corpusReviewTitle,PlainTextDocument)
#rm punc
corpusReviewTitle=tm_map(corpusReviewTitle,removePunctuation)
#removing numbers from corpus
corpusReviewTitle=tm_map(corpusReviewTitle,removeNumbers)
#stop words
corpusReviewTitle=tm_map(corpusReviewTitle,removeWords,c('hotel',stopwords('en')))
#stem
corpusReviewTitle=tm_map(corpusReviewTitle,stemDocument)
#dtm
dtmReviewTitle=DocumentTermMatrix(corpusReviewTitle)
#removing less repeated words from document term matrix,keeping only words which 
#are repeated more than 10% of the times
SparseReviewTitle=removeSparseTerms(dtmReviewTitle,0.99)

#converting this to data frame
SparseReviewTitleDF=as.data.frame(as.matrix(SparseReviewTitle))

#Making word clouds with review title data

wordcloud(colnames(SparseReviewTitleDF),colSums(SparseReviewTitleDF),min.freq = 4,scale = c(4,0.5),colors=brewer.pal(9, "Blues"),random.color = TRUE)


#automated function to generate and save  the city level word clouds
Cities=c("delhi","beijing","chicago","dubai","vegas","london","montreal"
         ,"delhi","new york","francisco","shanghai")
#as I have added hotel named to the data set , I am only using
#the columns without the hotelname, i;e [1:1073]
for(cityName in Cities){
  #subsetting the data based on the City and Hotel names
  IndividualHotelReviews=subset(SparseReviewsDF,grepl(cityName,HotelName),drop = T);
  #storing wordcloud for this data
  pdf(paste(cityName,'.pdf'))
  wordcloud(colnames(IndividualHotelReviews[,1:1073]),colSums(IndividualHotelReviews[,1:1073]),min.freq = 50,scale = c(4,0.5),colors=brewer.pal(9, "Set1"),random.color = TRUE)
  dev.off()
}

<!----------------------------------------------------------------------------------
  #Working with the text topics for opinion or categoring the data
  install.packages('topicmodels')
library(topicmodels)

#starting position in topic modelling is choosen random
#we start from 5 different positions which is the nstart=5 value.
#as we have 5 starting positions , Its is wise to have 5 diffrent seeds, which will
#seed=5, to avoid conflict of starting position,I;e to avoid reproducability of
#same starts.

#we will leave few iterations , as we do not include random walk initially 
#as they might not be dirchlet's distribution, we call it as burn in period and 
#I am setting it to 4000.
#I am performing 2000 iterations to allocate words to the respective topics.

#we take every 500 th iteration for further use.,to avoid correlations between
#samples.
#best=TRUE to get best posterior probs

#K is number of topics we will have, this will be declared in the starting

install.packages('topicmodels')
library(topicmodels)

TopicDTM=removeSparseTerms(dtm,0.95)
rownames(TopicDTM)=ReviewsHotelName$HotelName
#parameters for gibbs sampling
Iterations=2000
burninPeriod=4000
thin=500
seed=c(20,12,121,2000,300)
nstart=5
best=TRUE

#I am setting the number of topics,
TopicsRequired=6

#running LDA using gibbs sampling
install.packages('RTextTools')
library(RTextTools)
#slam package
install.packages("slam")
library(slam)
#using slams 
dtm2 <- row_sums(TopicDTM)
#remove all docs without words, to remove the error with null values in row_sums
dtm3   <- TopicDTM[dtm2>0, ]           

LDAOut=LDA(dtm3,TopicsRequired,method="Gibbs",control = list(
  nstart=nstart, seed =seed , best=best, burnin = burninPeriod, iter = Iterations,
  thin=thin))
#writing the LDA output to topics
ldaOut.topics <- as.matrix(topics(LDAtext))
#Writing the hotel names as row names
rownames(ldaOut.topics)=rownames(dtm3)
write.csv(ldaOut.topics,"Topics.csv")
#writing down lda terms
ldaOut.terms <- as.data.frame(as.matrix(terms(LDAtext)))
write.csv(ldaOut.terms,'10TopicsTerms.csv')

#writing top 50 terms in each topic to the current directory
ldaOut.terms <- as.matrix(terms(LDAtext,50))
write.csv(ldaOut.terms,'Top50Terms.csv')

#writing Weights  associated with each topic assignment
topicProbabilities <- as.matrix(LDAtext@gamma)
write.csv(topicProbabilities,"TopicWeights.csv")


#creating topic models for city delhi
#you can create the topic models based on your dynamic input also
#however, I am going to perform analysis on delhi from now on.
ReviewsDelhiHotel=subset(ReviewsHotelName,grepl('delhi',HotelName),drop = T)

##Perfomring bag of words on delhi review
library(tm)
library(SnowballC)
#corpus
corpusDelhi=Corpus(VectorSource(ReviewsDelhiHotel$FullReview))
#lower
corpusDelhi=tm_map(corpusDelhi,tolower)
#plaitext
corpusDelhi=tm_map(corpusDelhi,PlainTextDocument)
#rm punc
corpusDelhi=tm_map(corpusDelhi,removePunctuation)
#removing numbers from corpus
corpusDelhi=tm_map(corpusDelhi,removeNumbers)

#stop words
corpusDelhi=tm_map(corpusDelhi,removeWords,c('hotel','india','delhi','room','stay','quot','night'
                                             ,stopwords('en')))
#stem
corpusDelhi=tm_map(corpusDelhi,stemDocument)
#dtm
dtmDelhi=DocumentTermMatrix(corpusDelhi)

#creating topic models for this delhi document term matrix
library(topicmodels)
#taking only less sparse terms into consideration
TopicDelhiDTM=removeSparseTerms(dtmDelhi,0.99)
#calcualting sum of rows 
rownames(TopicDTM)=ReviewsHotelName$HotelName
#parameters for gibbs sampling
Iterations=2000
burninPeriod=4000
thin=500
seed=c(20,12,121,2000,300)
nstart=5
best=TRUE

#I am setting the number of topics,
TopicsRequired=5

#running LDA using gibbs sampling
library(RTextTools)
#slam package
library(slam)
LDAOut=LDA(TopicDelhiDTM,TopicsRequired,method="Gibbs",control = list(
  nstart=nstart, seed =seed , best=best, burnin = burninPeriod, iter = Iterations,
  thin=thin))
#Process of creating the visulization for the text topics using LDAvis package
install.packages('LDAvis')
library(LDAvis)
#creating a method called TopicsModelsVisual to create topic model JSON file

TopicsModelsVisual=function(TopicModels , Corpus, DocumentTermMatrix)
{
  library(topicmodels)
  library(slam)
  library(dplyr)
  phi=posterior(LDAOut)$terms%>%as.matrix()
  theta=posterior(LDAOut)$topics%>%as.matrix()
  vocab=colnames(posterior(LDAOut)$terms)
  doc.length=row_sums(DocumentTermMatrix,na.rm = T)
  FrequencyDF=data.frame(Words=colnames(DocumentTermMatrix)
                         ,Freq=col_sums(DocumentTermMatrix))
  term.frequency=FrequencyDF$Freq;
  LDAVisual=LDAvis::createJSON(phi = phi,theta = theta,vocab = vocab
                               ,doc.length = doc.length,term.frequency = term.frequency)
  return(LDAVisual)
  
}
#calling the LDAvis function by inputting topic models which is LDAout, corpus for delhi 
#corpusDelhi and TopicDelhiDTM to calculate document length
LDAVisualJson=TopicsModelsVisual(LDAOut,corpusDelhi,TopicDelhiDTM)

#writing this Json as web application to the current directory


#writing the text topicsto csv files to analyze seperately
#writng top 50 terms in each topic, delhi topics
ldaOut.terms <- as.matrix(terms(LDAOut,50))
write.csv(ldaOut.terms,'Top50TermsDelhi.csv')
#writing the delhi LDA output to topics 
ldaOut.topics <- as.matrix(topics(LDAOut))
#Writing the hotel names as row names
rownames(ldaOut.topics)=ReviewsDelhiHotel$HotelName;
write.csv(ldaOut.topics,"TopicsDelhi.csv")
topicProbabilities <- as.matrix(LDAOut@gamma)
#adding hotelnames to it
rownames(topicProbabilities)=ReviewsDelhiHotel$HotelName;
write.csv(topicProbabilities,"DelhiTopicWeights.csv")

#plotting delhi corpus
install.packages('ggplot2')
install.pcakages('reshape2')
install.packages('RColorBrewer')
library(RColorBrewer)
library(ggplot2)
library(reshape2)
WordFrequencies=col_sums(TopicDelhiDTM)
WordFrequencies=sort(WordFrequencies,decreasing = TRUE)
WordFrequenciesDF <- data.frame(word=names(WordFrequencies), freq=WordFrequencies)
# Plot Histogram with basic features
ggplot(subset(WordFrequenciesDF, freq>1000),aes(word, freq)) +
  geom_bar(stat = 'identity') +scale_fill_brewer(name='Word frequencies',palette = 'Set3')
theme(axis.text.x=element_text(angle=45, hjust=1))

#ngram categorization
install.packages('ngram')
install.packages('RWeka')
library(RWeka)
library(ngram)
#Using tokenizer for more combinations
#function for one gram tokenizer
OneWord <- function(x) NGramTokenizer(x, Weka_control(min = 1, max =1))
#calling the above function in corpus
#run all the commands till plotting plotTwoGram
ngramdtm <- DocumentTermMatrix(corpusDelhi, control = list(tokenize =OneWord ))
freq <- sort(colSums(as.matrix(ngramdtm)), decreasing=TRUE)
onegramDF <- data.frame(word=names(freq), freq=freq)

# using brewer function to color all the choices

colourCount = nrow(subset(onegramDF,freq>1000))
getPalette = colorRampPalette(brewer.pal(9, "Set2"))

plotOneGram <- ggplot(subset(onegramDF, freq > 1000) ,aes(word, freq))
plotOneGram <- plotOneGram + geom_bar(stat="identity",aes(word,freq,fill=getPalette(colourCount)))
plotOneGram + theme(axis.text.x=element_text(angle=45, hjust=1)) + ggtitle("Uni-Gram Frequency")

#Using tokenizer for more combinations
#function for two gram tokenizer
TwoWordsCombination=function(x)NGramTokenizer(x,Weka_control(min=2,max=2))
#calling the above function in corpus
TwoGramDtm=DocumentTermMatrix(corpusDelhi,control = list(tokenize=TwoWordsCombination))

#removing less repeated
#run all the commands till plotting plotTwoGram
TwoGramDtm=removeSparseTerms(TwoGramDtm,0.99)
#saving this data to a data frame after sorting
freqTwo <- sort(colSums(as.matrix(TwoGramDtm)), decreasing=TRUE)
TwoGramDF <- data.frame(word=names(freqTwo), freq=freqTwo)

#plotting it
# using brewer function to color all the choices
colourCount = nrow(subset(TwoGramDF,freq>100))
getPalette = colorRampPalette(brewer.pal(9, "Set2"))

plotTwogram <- ggplot(subset(TwoGramDF, freq>100 ) ,aes(word, freq))
plotTwogram <- plotTwogram + geom_bar(stat="identity",aes(word,freq,fill=getPalette(colourCount)))
plotTwogram + theme(axis.text.x=element_text(angle=45, hjust=1)) + ggtitle("two-word Frequency")

#three word in a senctence using n gram
ThreeWordsCombination=function(x)NGramTokenizer(x,Weka_control(min=3,max=3))
#calling this function in corpus
ThreeGramDtm=DocumentTermMatrix(corpusDelhi,control = list(tokenize=ThreeWordsCombination))

#removing less repeated
#run all the commands till plotting plotThreeGram
ThreeGramDtm=removeSparseTerms(ThreeGramDtm,0.999)
#saving this data to a data frame after sorting
freqThree <- sort(colSums(as.matrix(ThreeGramDtm)), decreasing=TRUE)
ThreeGramDF <- data.frame(word=names(freqThree), freq=freqThree)
#plotting it
# using brewer function to color all the choices

colourCount = nrow(subset(wofThree,freq>25))
getPalette = colorRampPalette(brewer.pal(8, "Set2"))

plotThreeGram <- ggplot(subset(ThreeGramDF, freq>25 ))
plotThreeGram <- plotThreeGram + geom_bar(stat="identity",aes(word,freq,fill=getPalette(colourCount)))
plotThreeGram + theme(axis.text.x=element_text(angle=45, hjust=1)) + ggtitle("Three Word Frequency")
