using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Description;
// using xRLNetLibs;

namespace ZoaksImgRegServicesEntity
{
    class Program
    {
        static ServiceHost host = null;
        static void Main(string[] args)
        {
            string baseAddress = string.Empty;
            try
            {
                // string _hostip;
                //_hostip = NetHelper.GetMachineIP();
               // baseAddress = "http://" + _hostip + ":8099/zservices";//"http://localhost:6688/zservices";
                baseAddress = "http://60.199.208.101:8099/zservices";
                host = new ServiceHost(typeof(ZoaksImgRegServices.CocaService), new Uri(baseAddress));
                host.AddServiceEndpoint(typeof(ZoaksImgRegServices.ICocaService), new WebHttpBinding(), "").Behaviors.Add(new WebHttpBehavior());
                //host.State = CommunicationState.Opening;
                host.Open();
                if (host.State == CommunicationState.Opened)
                {
                    Console.WriteLine("ZServices Started at address: " + baseAddress);

                    char haltchar = 'q';
                    char _c = 'k';
                    while (_c != haltchar)
                    {
                        _c = Convert.ToChar(Console.Read());
                    }
                    host.Close();
                    Console.WriteLine("ZServices Stoped at address: " + baseAddress);
                }
                else
                {
                    Console.WriteLine("ZServices Failed at address: " + baseAddress);
                }
            }
            catch (Exception err)
            {
                Console.WriteLine(err.Message + "\r\n");
                Console.WriteLine("baseAddress : " + baseAddress);
            }

        }

    }
}
