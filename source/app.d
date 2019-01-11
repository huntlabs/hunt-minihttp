/*
 * Hunt - A refined core library for D programming language.
 *
 * Copyright (C) 2015-2018  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs.cn
 *
 * Licensed under the Apache-2.0 License.
 *
 */

import std.getopt;
import std.stdio;

import hunt.io;
import hunt.system.Memory;

version(Posix) {
	import http.Processor;
	import http.Server;
	import DemoProcessor;
	import HttpBenchmarkProcessor;
} else {
	import HttpServer;
}



void main(string[] args) {

	// benchmark(10000);

	ushort port = 8080;
	GetoptResult o = getopt(args, "port|p", "Port (default 8080)", &port);
	if (o.helpWanted) {
		defaultGetoptPrinter("A simple http server powered by Hunt!", o.options);
		return;
	}


version(Posix) {
	auto httpServer = new HttpServer!(DemoProcessor)("0.0.0.0", port, totalCPUs-1);
} else {
	auto httpServer = new HttpServer("0.0.0.0", port, totalCPUs-1);
}
	writefln("listening on http://%s", httpServer.bindingAddress.toString());
	httpServer.start();
}

