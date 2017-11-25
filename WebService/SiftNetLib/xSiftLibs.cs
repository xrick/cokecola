using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Emgu.CV;
using Emgu.CV.UI;
using Emgu.CV.CvEnum;
using Emgu.CV.Structure;
using Emgu.CV.Features2D;
using System.Diagnostics;
using System.IO;
using System.Drawing;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
namespace SiftNetLib
{
    public class xSiftLibs
    {
        public xSiftLibs() { }


        #region Static Utility Method
        
        //public static string DoImageRegonition(string FullFeaFName, Stream ImgStream)
        
        public static Dictionary<string, string> DoImageRegonition(string[] SevenFeas,string[] CocaFeas, Stream ImgStream)
        {
            
            Dictionary<string,string> regres = new Dictionary<string,string>(4);
            StringBuilder sb = new StringBuilder();
            const int Seven_DV = 400;
            const int Coca_DV = 300;
            try
            {
                SIFTDetector siftdector = new SIFTDetector();
                //the following code is unnecessary because we will extract the feature first.
                // this other way this image is pre-transformed to gray-scale. 
                //the following codes are needed to be refactory
                // Image<Gray, Byte> modelImage = new Image<Gray, byte>(FullMoldeImg);
                //Image<Gray, Byte> modelImage = new Image<Gray, byte>(FullMoldeImgName);
                BinaryFormatter _bf = new BinaryFormatter();
                int sevenlen = SevenFeas.Length;
                int cocalen = CocaFeas.Length;
                //initial the dictionary variable
                
                regres.Add("seven","no");
                regres.Add("coca","no");
                regres.Add("ma", "none");
                regres.Add("excep","none");
                
                //Initialize the image that to be comparased
                Image<Gray, Byte> observedImage = GetCVImage(ImgStream);
                MKeyPoint[] objmkps = siftdector.DetectKeyPoints(observedImage);
                ImageFeature[] imageFeatures = siftdector.ComputeDescriptors(observedImage, objmkps);

                //PointF[] _obimgPA = GetPointFfromFeatures(imageFeatures, imageFeatures.Length);
                //int _obimgPN = _obimgPA.Length;
                
                //Doing seven matching
                
                for(int idx=0; idx<sevenlen;idx++)
                {
                    //Get the feature file
                    Stream stream = File.Open(SevenFeas[idx], FileMode.Open);
                    //Deserilizing the file to get the feature
                    ImageFeature[] sevenFeatures = (ImageFeature[])_bf.Deserialize(stream);
                    stream.Dispose();
                    int slen = sevenFeatures.Length;
                    //PointF[] sevenPA = GetPointFfromFeatures(sevenFeatures, _obimgPN);
                   
                    
                    //set up the tractor
                    Features2DTracker seventrac = new Features2DTracker(sevenFeatures);
                    ////Doing seven matching
                    Features2DTracker.MatchedImageFeature[] sevenmatchedfea = seventrac.MatchFeature(imageFeatures, 2, 20);
                    sevenmatchedfea = Features2DTracker.VoteForUniqueness(sevenmatchedfea, 0.8);
                    sevenmatchedfea = Features2DTracker.VoteForSizeAndOrientation(sevenmatchedfea, 1.5, 20);
                     
                    //Get matching result matrix
                    HomographyMatrix sevenhomography = Features2DTracker.GetHomographyMatrixFromMatchedFeatures(sevenmatchedfea);
                    //Matrix<float>  sevenhomography =  CameraCalibration.FindHomography(sevenPA,_obimgPA,HOMOGRAPHY_METHOD.RANSAC,3).Convert<float>();
                    //sevenmatchedfea.
                    //fill result into dictionary variable
                    if (sevenhomography != null)
                    {
                        if (Math.Abs(sevenhomography.Sum) > Seven_DV)
                        {
                            regres["seven"] = "yes";
                        }
                        
                        sb.Append("ssum:");
                        sb.Append(sevenhomography.Sum.ToString());
                        //sb.Append("| sidx:");
                       // sb.Append(idx.ToString());
                        
                        break;
                    }
                }

                //Doing Coca image matching
                for (int idx2 = 0; idx2 < cocalen; idx2++)
                {
                    //Get the feature file
                    Stream stream = File.Open(CocaFeas[idx2], FileMode.Open);
                    //Deserilizing the file to get the feature
                    ImageFeature[] cocaFeatures = (ImageFeature[])_bf.Deserialize(stream);
                    stream.Dispose();
                    //PointF[] cocaPA = GetPointFfromFeatures(cocaFeatures, _obimgPN);
                    //cocaFeatures.CopyTo(cocaPA, 0);
                   
                    //Matrix<float> cocahomography = CameraCalibration.FindHomography(cocaPA, _obimgPA, HOMOGRAPHY_METHOD.RANSAC, 3).Convert<float>();
                    //set up the tractor
                    Features2DTracker cocatrac = new Features2DTracker(cocaFeatures);
                    ////Doing seven matching
                    Features2DTracker.MatchedImageFeature[] cocamatchedfea = cocatrac.MatchFeature(imageFeatures, 2, 20);
                    cocamatchedfea = Features2DTracker.VoteForUniqueness(cocamatchedfea, 0.8);
                    cocamatchedfea = Features2DTracker.VoteForSizeAndOrientation(cocamatchedfea, 1.5, 20);
                    //Get matching result matrix
                    HomographyMatrix cocahomography = Features2DTracker.GetHomographyMatrixFromMatchedFeatures(cocamatchedfea);
                    //fill result into dictionary variable
                    if (cocahomography != null)
                    {
                        if (Math.Abs(cocahomography.Sum) > Coca_DV)
                        {
                            regres["coca"] = "yes";
                        }
                        sb.Append("#csum:");
                        sb.Append(cocahomography.Sum.ToString());
                        //sb.Append(",cidx:");
                        //sb.Append(idx2.ToString());
                        break;
                    }
                }
               
            }
            catch (Exception err)
            {
                regres["excep"] = err.Message;
                Console.WriteLine(err.Message);
            }
            if (sb.Length > 0)
            {
                regres["ma"] = sb.ToString();
                sb = null;
            }
            return regres;
        }
        

        public static Image<Gray, Byte> GetCVImage(Stream ImgFileContent)
        {
            StreamReader sr = new StreamReader(ImgFileContent, Encoding.ASCII);
            string base64str = sr.ReadToEnd();
            byte[] pngfile = Convert.FromBase64String(base64str);
            Stream stream = new MemoryStream(pngfile);
            Bitmap _bitmap = new Bitmap(stream);
            Image<Gray, Byte> retimg = new Image<Gray, byte>(_bitmap);
            stream.Close();
            stream.Dispose();
            return retimg;
            //Stream stream = Stream.File.Create(fname);
            //fs.Write(pngfile, 0, pngfile.Length - 1);
            //fs.Flush();
        }

        //very bad codes
        public static PointF[] GetPointFfromFeatures(ImageFeature[] imagefeatures,int ArySize)
        {
            if (imagefeatures != null)
            {
                int iflen = imagefeatures.Length;
                int iflen2 = iflen;
                if (iflen > ArySize)
                    iflen2 = ArySize;
                PointF[] imagePA = new PointF[ArySize];

                for (int idx3 = 0; idx3 < iflen2; idx3++)
                {
                    imagePA[idx3] = imagefeatures[idx3].KeyPoint.Point;
                }

                if (iflen < ArySize)
                {
                    for (int idx4 = iflen; idx4 < ArySize; idx4++)
                    {
                        imagePA[idx4] = new PointF(0L, 0L);
                    }
                }
                return imagePA;
            }
            return null;
        }

      #endregion
    }
}
