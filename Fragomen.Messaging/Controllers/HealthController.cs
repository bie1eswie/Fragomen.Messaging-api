using Fragomen.Infrastructure;
using Microsoft.AspNetCore.Mvc;

namespace Fragomen.Messaging.Controllers
{
    public class HealthController : ApiControllerBase
    {
        [HttpGet]
        public IActionResult Get()
        {
            return Ok("I am well");
        }
    }
}
