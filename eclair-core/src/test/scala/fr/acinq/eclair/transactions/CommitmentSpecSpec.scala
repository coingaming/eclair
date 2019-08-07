/*
 * Copyright 2019 ACINQ SAS
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package fr.acinq.eclair.transactions

import fr.acinq.bitcoin.{ByteVector32, Crypto}
import fr.acinq.eclair.{MilliSatoshi, TestConstants, randomBytes32}
import fr.acinq.eclair.wire.{UpdateAddHtlc, UpdateFailHtlc, UpdateFulfillHtlc}
import org.scalatest.FunSuite


class CommitmentSpecSpec extends FunSuite {
  test("add, fulfill and fail htlcs from the sender side") {
    val spec = CommitmentSpec(htlcs = Set(), feeratePerKw = 1000, toLocal = MilliSatoshi(5000000), toRemote = MilliSatoshi(0))
    val R = randomBytes32
    val H = Crypto.sha256(R)

    val add1 = UpdateAddHtlc(ByteVector32.Zeroes, 1, MilliSatoshi(2000 * 1000), H, 400, TestConstants.emptyOnionPacket)
    val spec1 = CommitmentSpec.reduce(spec, add1 :: Nil, Nil)
    assert(spec1 === spec.copy(htlcs = Set(DirectedHtlc(OUT, add1)), toLocal = MilliSatoshi(3000000)))

    val add2 = UpdateAddHtlc(ByteVector32.Zeroes, 2, MilliSatoshi(1000 * 1000), H, 400, TestConstants.emptyOnionPacket)
    val spec2 = CommitmentSpec.reduce(spec1, add2 :: Nil, Nil)
    assert(spec2 === spec1.copy(htlcs = Set(DirectedHtlc(OUT, add1), DirectedHtlc(OUT, add2)), toLocal = MilliSatoshi(2000000)))

    val ful1 = UpdateFulfillHtlc(ByteVector32.Zeroes, add1.id, R)
    val spec3 = CommitmentSpec.reduce(spec2, Nil, ful1 :: Nil)
    assert(spec3 === spec2.copy(htlcs = Set(DirectedHtlc(OUT, add2)), toRemote = MilliSatoshi(2000000)))

    val fail1 = UpdateFailHtlc(ByteVector32.Zeroes, add2.id, R)
    val spec4 = CommitmentSpec.reduce(spec3, Nil, fail1 :: Nil)
    assert(spec4 === spec3.copy(htlcs = Set(), toLocal = MilliSatoshi(3000000)))
  }

  test("add, fulfill and fail htlcs from the receiver side") {
    val spec = CommitmentSpec(htlcs = Set(), feeratePerKw = 1000, toLocal = MilliSatoshi(0), toRemote = MilliSatoshi(5000 * 1000))
    val R = randomBytes32
    val H = Crypto.sha256(R)

    val add1 = UpdateAddHtlc(ByteVector32.Zeroes, 1, MilliSatoshi(2000 * 1000), H, 400, TestConstants.emptyOnionPacket)
    val spec1 = CommitmentSpec.reduce(spec, Nil, add1 :: Nil)
    assert(spec1 === spec.copy(htlcs = Set(DirectedHtlc(IN, add1)), toRemote = MilliSatoshi(3000 * 1000)))

    val add2 = UpdateAddHtlc(ByteVector32.Zeroes, 2, MilliSatoshi(1000 * 1000), H, 400, TestConstants.emptyOnionPacket)
    val spec2 = CommitmentSpec.reduce(spec1, Nil, add2 :: Nil)
    assert(spec2 === spec1.copy(htlcs = Set(DirectedHtlc(IN, add1), DirectedHtlc(IN, add2)), toRemote = MilliSatoshi(2000 * 1000)))

    val ful1 = UpdateFulfillHtlc(ByteVector32.Zeroes, add1.id, R)
    val spec3 = CommitmentSpec.reduce(spec2, ful1 :: Nil, Nil)
    assert(spec3 === spec2.copy(htlcs = Set(DirectedHtlc(IN, add2)), toLocal = MilliSatoshi(2000 * 1000)))

    val fail1 = UpdateFailHtlc(ByteVector32.Zeroes, add2.id, R)
    val spec4 = CommitmentSpec.reduce(spec3, fail1 :: Nil, Nil)
    assert(spec4 === spec3.copy(htlcs = Set(), toRemote = MilliSatoshi(3000 * 1000)))
  }
}
