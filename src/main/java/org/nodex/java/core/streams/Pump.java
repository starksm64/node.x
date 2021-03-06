/*
 * Copyright 2002-2011 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of the
 * License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

package org.nodex.java.core.streams;

import org.nodex.java.core.EventHandler;
import org.nodex.java.core.buffer.Buffer;

public class Pump {
  private final ReadStream readStream;
  private final WriteStream writeStream;

  private int pumped;

  private final EventHandler<Void> drainHandler = new EventHandler<Void>() {
    public void onEvent(Void v) {
      readStream.resume();
    }
  };

  private final EventHandler<Buffer> dataHandler = new EventHandler<Buffer>() {
    public void onEvent(Buffer buffer) {
      writeStream.writeBuffer(buffer);
      pumped += buffer.length();
      if (writeStream.writeQueueFull()) {
        readStream.pause();
        writeStream.drainHandler(drainHandler);
      }
    }
  };

  public Pump(ReadStream rs, WriteStream ws) {
    this.readStream = rs;
    this.writeStream = ws;
  }

  public Pump(ReadStream rs, WriteStream ws, int maxWriteQueueSize) {
    this(rs, ws);
    this.writeStream.setWriteQueueMaxSize(maxWriteQueueSize);
  }

  public void setWriteQueueMaxSize(int maxSize) {
    this.writeStream.setWriteQueueMaxSize(maxSize);
  }

  public void start() {
    readStream.dataHandler(dataHandler);
  }

  public void stop() {
    writeStream.drainHandler(null);
    readStream.dataHandler(null);
  }

  public int getBytesPumped() {
    return pumped;
  }

}
