using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using System.IO;
using SiftNetLib;

namespace ZoaksImgRegServices
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "Service1" in code, svc and config file together.
    public class CocaService : ICocaService
    {
        const string NewLine = "\r\n";
        public string GetData(int value)
        {
            return string.Format("You entered: {0}", value);
        }

        public CompositeType GetDataUsingDataContract(CompositeType composite)
        {
            if (composite == null)
            {
                throw new ArgumentNullException("composite");
            }
            if (composite.BoolValue)
            {
                composite.StringValue += "Suffix";
            }
            return composite;
        }

        //public string DoImgRegonition(string VendorName, Stream FileContent)
        public Dictionary<string, string> DoImgRegonition(string VendorName, Stream FileContent)
        {
           
                Dictionary<string, string> regresult = new Dictionary<string, string>();
                string[] sevenfeas = new string[1] { "C:\\imgregtmp\\features\\sevenfea_1.fea" };
                string[] cocafeas = new string[2] { "C:\\imgregtmp\\features\\cocafea_1.fea", "C:\\imgregtmp\\features\\cocafea_2.fea" };
                regresult = SiftNetLib.xSiftLibs.DoImageRegonition(sevenfeas, cocafeas, FileContent);
                Console.WriteLine("Get request at time: ");
                Console.WriteLine(DateTime.Now.ToLongDateString());
                Console.WriteLine("||");
                Console.WriteLine(DateTime.Now.ToLongTimeString());
                Console.WriteLine("  || Received Data: ");
                Console.WriteLine(regresult.ToString());
                Console.WriteLine("\r\n");
                return regresult;
                /*********************Original Test Code*********************/
                /*
                string fname = "C:\\imgregtmp\\im" + DateTime.Now.Ticks.ToString() + ".jpg";
                StreamReader sr = new StreamReader(FileContent, Encoding.ASCII);
                string base64str = sr.ReadToEnd();

                // string base64str = EncodingHelper.Base64EncodingHelper.base64Encode("C:\\imgregtmp\\7-11_007_2.png");

                byte[] pngfile = Convert.FromBase64String(base64str);//EncodingHelper.Base64EncodingHelper.base64Decode(base64str);
                FileStream fs = File.Create(fname);
                fs.Write(pngfile, 0, pngfile.Length - 1);
                fs.Flush();
                fs.Close();
                fs.Dispose();
                /*************************************************************/
                /*===============================================================================
                int bytelen = (int)FileContent.Length;
                byte[] base65bytes = new byte[bytelen];
                FileContent.Read(base65bytes,0,(int)FileContent.Length-1);

                System.Text.UTF8Encoding encoder = new System.Text.UTF8Encoding();
                System.Text.Decoder utf8Decode = encoder.GetDecoder();
                 int charCount = 0;
                char[] decoded_char = new char[charCount];
                utf8Decode.GetChars(base65bytes, 0, base65bytes.Length, decoded_char, 0);
                string base64str = new String(decoded_char);
                byte[] pngfile = EncodingHelper.Base64EncodingHelper.base64Decode(base64str);

                FileStream fs = File.Create(fname);
                fs.Write(pngfile,0,pngfile.Length-1);
                fs.Flush();
                fs.Close();
                fs.Dispose();*/
               // byte[] buffer = new byte[10000];
               // int bytesRead, totalBytesRead = 0;
                /*
                do
                {
                    bytesRead = FileContent.Read(buffer, 0, buffer.Length);
                    fs.Write(buffer, 0, buffer.Length - 1);
                    totalBytesRead += bytesRead;
                } while (bytesRead > 0);
               =============================================================================*/
                //.WriteLine("Service: Received file {0} with {1} bytes", VendorName, totalBytesRead);
                //return string.Format("Service: Received file {0} with {1} bytes." + NewLine, VendorName, pngfile.Length.ToString());
        }
    }
}
