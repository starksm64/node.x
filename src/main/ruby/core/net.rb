# Copyright 2002-2011 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

include Java

module Nodex

  class NetBase

    def initialize(j_cliserv)
      j_cliserv = j_cliserv
    end

    def ssl=(val)
      @j_cliserv.setSSL(val)
    end

    def key_store_path=(val)
      @j_cliserv.setKeyStorePath(val)
    end

    def key_store_password=(val)
      @j_cliserv.setKeyStorePassword(val)
    end

    def trust_store_path=(val)
      @j_cliserv.setTrustStorePath(val)
    end

    def trust_store_password=(val)
      @j_cliserv.setTrustStorePassword(val)
    end

    def send_buffer_size=(val)
      @j_cliserv.setSendBufferSize(val)
    end

    def receive_buffer_size=(val)
      @j_cliserv.setReceiveBufferSize(val)
    end

    def keep_alive=(val)
      @j_cliserv.setKeepAlive(val)
    end

    def reuse_address=(val)
      @j_cliserv.setReuseAddress(val)
    end

    def so_linger=(val)
      @j_cliserv.setSoLinger(val)
    end

    def traffic_class=(val)
      @j_cliserv.setTrafficClass(val)
    end

    private :initialize
  end

  class NetServer < NetBase

    def initialize
      @j_cliserv = org.nodex.java.core.net.NetServer.new
      super(@j_cliserv)

      puts "created net server"
    end

    def client_auth_required=(val)
      @j_cliserv.setClientAuthRequired(val)
    end

    def connect_handler(proc = nil, &hndlr)
      hndlr = proc if proc
      @j_cliserv.connectHandler { |j_socket| hndlr.call(NetSocket.new(j_socket)) }
    end

    def listen(port, host = "0.0.0.0")
      puts "listening"
      @j_cliserv.listen(port, host)
      self
    end

    def close(&hndlr)
      @j_cliserv.close(hndlr)
    end

  end

  class NetClient < NetBase

    def initialize
      @j_cliserv = org.nodex.java.core.net.NetClient.new
      super(@j_cliserv)
    end

    def trust_all=(val)
      @j_cliserv.setTrustAll(val)
    end

    def connect(port, host = "localhost", proc = nil, &hndlr)
      hndlr = proc if proc
      @j_cliserv.connect(port, host) { |j_socket| hndlr.call(NetSocket.new(j_socket)) }
    end

    def close
      @j_cliserv.close
    end

  end

  class NetSocket

    def initialize(j_socket)
      @j_socket = j_socket
      @write_handler_id = Nodex::register_handler { |buffer|
        write_buffer(buffer)
      }
      @j_socket.closedHandler(Proc.new {
        Nodex::unregister_handler(@write_handler_id)
        @closed_handler.call if @closed_handler
      })
    end

    def write_buffer(buff, &compl)
      j_buff = buff._to_java_buffer
      if compl == nil
        @j_socket.write(j_buff)
      else
        @j_socket.write(j_buff, compl)
      end
    end

    def write_str(str, enc = nil, &compl)
      if (compl == nil)
        @j_socket.writeString(str, enc)
      else
        @j_socket.writeString(str, enc, compl)
      end
    end

    def data_handler(proc = nil, &hndlr)
      hndlr = proc if proc
      @j_socket.dataHandler { |j_buff| hndlr.call(Buffer.new(j_buff)) }
    end

    def end_handler(proc = nil, &hndlr)
      hndlr = proc if proc
      @j_socket.endHandler(hndlr)
    end

    def closed_handler(proc = nil, &hndlr)
      hndlr = proc if proc
      @closed_handler = hndlr;
    end

    def exception_handler(proc = nil, &hndlr)
      hndlr = proc if proc
      @j_socket.exceptionHandler(hndlr)
    end

    def drain_handler(proc = nil, &hndlr)
      hndlr = proc if proc
      @j_socket.drainHandler(hndlr)
    end

    def send_file(file_path)
      @j_socket.sendFile(file_path)
    end

    def pause
      @j_socket.pause
    end

    def resume
      @j_socket.resume
    end

    def write_queue_max_size=(val)
      @j_socket.setWriteQueueMaxSize(val)
    end

    def write_queue_full?
      @j_socket.writeQueueFull()
    end

    def close
      @j_socket.close
    end

    def _to_read_stream
      @j_socket
    end

    def _to_write_stream
      @j_socket
    end

    def write_handler_id
      @write_handler_id
    end

    private :initialize
  end
end

