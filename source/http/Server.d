module http.Server;

version(Posix):
import std.stdio;

import hunt.concurrency.thread.Helper;
import hunt.event;
import hunt.io;
import hunt.logging;
import hunt.system.Memory;
import hunt.util.DateTime;
import hunt.util.Timer;

import std.array;
import std.conv;
import std.json;
import std.socket;
import std.string;


import http.Parser;
import http.Processor;

// https://www.techempower.com/benchmarks/

shared static this() {
	DateTimeHelper.startClock();
}


/**
*/
abstract class AbstractTcpServer {
	protected EventLoopGroup _group = null;
	protected bool _isStarted = false;
	protected Address _address;
	TcpStreamOption _tcpStreamoption;

	this(Address address, int thread = (totalCPUs - 1)) {
		this._address = address;
		_tcpStreamoption = TcpStreamOption.createOption();
		_group = new EventLoopGroup(cast(uint) thread);
	}

	@property Address bindingAddress() {
		return _address;
	}

	void start() {
		if (_isStarted)
			return;
		debug trace("start to listen:");
		_isStarted = true;

		Socket server = new TcpSocket();
		server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
		server.bind(new InternetAddress("0.0.0.0", 8080));
		server.listen(1000);

		debug trace("Launching server");

		_group.start();

		while (true) {
			try {
				version (HUNT_DEBUG)
					trace("Waiting for server.accept()");
				Socket socket = server.accept();
				version (HUNT_DEBUG) {
					infof("new client from %s, fd=%d", socket.remoteAddress.toString(), socket.handle());
				}
				version(HUNT_METRIC) {
                    import core.time;
                    debug trace("processing client...");
                    MonoTime startTime = MonoTime.currTime;
                }
				EventLoop loop = _group.nextLoop();
				TcpStream stream = new TcpStream(loop, socket, _tcpStreamoption);
				onConnectionAccepted(stream);
				version(HUNT_METRIC) {
                    Duration timeElapsed = MonoTime.currTime - startTime;
                    warningf("client processing done in: %d microseconds",
                        timeElapsed.total!(TimeUnit.Microsecond)());
                }
			} catch (Exception e) {
				warningf("Failure on accept %s", e);
				break;
			}
		}
		_isStarted = false;
	}

	protected void onConnectionAccepted(TcpStream client);

	void stop() {
		if (!_isStarted)
			return;
		_isStarted = false;
		_group.stop();
	}
}

alias ProcessorCreater = HttpProcessor delegate(TcpStream client);

/**
*/
class HttpServer(T) : AbstractTcpServer if(is(T : HttpProcessor)) {

	this(string ip, ushort port, int thread = (totalCPUs - 1)) {
		super(new InternetAddress(ip, port), thread);
	}

	this(Address address, int thread = (totalCPUs - 1)) {
		super(address, thread);
	}

	override protected void onConnectionAccepted(TcpStream client) {
		T httpProcessor = new T(client);
		httpProcessor.run();
	}
}
