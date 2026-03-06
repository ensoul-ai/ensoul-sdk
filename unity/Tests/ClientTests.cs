using System.Net;
using System.Net.Http;
using NUnit.Framework;

namespace Ensoul.Tests
{
    [TestFixture]
    public class ClientTests
    {
        [Test]
        public void Constructor_WithApiKey_DoesNotThrow()
        {
            Assert.DoesNotThrow(() =>
            {
                using var client = new EnsoulClient("test-key");
            });
        }

        [Test]
        public void Constructor_AllResourceNamespaces_AreNotNull()
        {
            using var client = new EnsoulClient("test-key");
            Assert.That(client.Personas, Is.Not.Null);
            Assert.That(client.Chat, Is.Not.Null);
            Assert.That(client.Domains, Is.Not.Null);
            Assert.That(client.Simulations, Is.Not.Null);
            Assert.That(client.Aggregate, Is.Not.Null);
            Assert.That(client.Memory, Is.Not.Null);
            Assert.That(client.Sessions, Is.Not.Null);
            Assert.That(client.Frameworks, Is.Not.Null);
            Assert.That(client.Auth, Is.Not.Null);
            Assert.That(client.Health, Is.Not.Null);
            Assert.That(client.Info, Is.Not.Null);
        }

        [Test]
        public void Dispose_DoesNotThrow()
        {
            var client = new EnsoulClient("test-key");
            Assert.DoesNotThrow(() => client.Dispose());
        }

        [Test]
        public void Version_Is_0_1_0()
        {
            Assert.That(EnsoulClient.Version, Is.EqualTo("0.1.0"));
        }

        [Test]
        public void WithHttpClient_CreatesWorkingClient()
        {
            var handler = new MockHttpHandler
            {
                Handler = _ => System.Threading.Tasks.Task.FromResult(
                    MockHttpHandler.MakeResponse(HttpStatusCode.OK, "{}"))
            };
            var config = new EnsoulConfig(apiKey: "key");
            using var client = EnsoulClient.WithHttpClient(config, handler);
            Assert.That(client, Is.Not.Null);
            Assert.That(client.Personas, Is.Not.Null);
        }

        [Test]
        public void Personas_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Personas, Is.Not.Null);
        }

        [Test]
        public void Chat_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Chat, Is.Not.Null);
        }

        [Test]
        public void Domains_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Domains, Is.Not.Null);
        }

        [Test]
        public void Simulations_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Simulations, Is.Not.Null);
        }

        [Test]
        public void Aggregate_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Aggregate, Is.Not.Null);
        }

        [Test]
        public void Memory_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Memory, Is.Not.Null);
        }

        [Test]
        public void Sessions_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Sessions, Is.Not.Null);
        }

        [Test]
        public void Frameworks_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Frameworks, Is.Not.Null);
        }

        [Test]
        public void Auth_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Auth, Is.Not.Null);
        }

        [Test]
        public void Health_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Health, Is.Not.Null);
        }

        [Test]
        public void Info_IsNotNull()
        {
            using var client = new EnsoulClient("k");
            Assert.That(client.Info, Is.Not.Null);
        }
    }
}
