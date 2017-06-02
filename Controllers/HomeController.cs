using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using System.Net.Http;
using Newtonsoft.Json;
using clivisui.Models;
using Microsoft.Extensions.Options;

namespace clivisui.Controllers
{
    public class HomeController : Controller
    {
        public int RefreshPeriod { get; set; } = 300;
        public AppConfig AppConfigs { get; }

        public HomeController(IOptions<AppConfig> configs)
        {
            AppConfigs = configs.Value;
            /*if((AppConfigs.ServiceURL == null) || (AppConfigs.ServiceURL == string.Empty))
            {
                throw new ArgumentNullException("ServiceURL is null or empty");
            } */                           
        }

        public IActionResult Index()
        {

            ViewData["PingDataOut"] = "-10.0";
            ViewData["PingDataIn"] = "20.0";
            Response.Headers.Add("Refresh", "1");

            return View();
        }

        public IActionResult Netatmo()
        {
            HttpClient client = new HttpClient();
            //var uri = new UriBuilder("http://docker-sr7eo120.cloudapp.net:5050")
            var uri = new UriBuilder(AppConfigs.ServiceURL)
            {
                Path = "/api/climate/Netatmo"
            }.Uri;    
                    
            var resp = client.GetAsync(uri).Result;
            string response = "";
            response = resp.Content.ReadAsStringAsync().Result;
            ClimateItem reading = new ClimateItem();
           reading = JsonConvert.DeserializeObject<ClimateItem>(response);
            try
            {
                ViewData["NetatmoIndoor"] = reading.IndoorValue;
                ViewData["NetatmoOutdoor"] = reading.OutdoorValue;
            }
            catch (NullReferenceException)
            {
                ViewData["NetatmoIndoor"] = "0.0";
                ViewData["NetatmoOutdoor"] = "0.0";
            }
            Response.Headers.Add("Refresh", RefreshPeriod.ToString());

            return View();
        }

        public IActionResult Nibe()
        {
            HttpClient client = new HttpClient();
            //var uri = new UriBuilder("http://docker-sr7eo120.cloudapp.net:5050")
            var uri = new UriBuilder(AppConfigs.ServiceURL)
            {
                Path = "/api/climate/Nibe"
            }.Uri;    
                    
            var resp = client.GetAsync(uri).Result;
            string response = "";
            response = resp.Content.ReadAsStringAsync().Result;
            ClimateItem reading = new ClimateItem();
           reading = JsonConvert.DeserializeObject<ClimateItem>(response);

            try
            {
                ViewData["NibeIndoor"] = reading.IndoorValue;
                ViewData["NibeOutdoor"] = reading.OutdoorValue;
            }
            catch (NullReferenceException)
            {
                ViewData["NibeIndoor"] = "0.0";
                ViewData["NibeOutdoor"] = "0.0";
            }
            Response.Headers.Add("Refresh", RefreshPeriod.ToString());

            return View();
        }

        public IActionResult Ping()
        {
            ViewData["PingDataOut"] = "-10.0";
            ViewData["PingDataIn"] = "20.0";
            Response.Headers.Add("Refresh", "1");

            return View();
        }

        public IActionResult Error()
        {
            return View();
        }
    }
}
