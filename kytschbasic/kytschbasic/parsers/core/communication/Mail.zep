/**
 * Mail parser
 *
 * @package     KytschBASIC\Parsers\Core\Communication\Mail
 * @author 		Mike Welsh <hello@kytschi.com>
 * @copyright   2025 Mike Welsh
 * @link 		https://kytschbasic.org
 * @version     0.0.1
 *
 * Copyright 2025 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */
namespace KytschBASIC\Parsers\Core\Communication;

use KytschBASIC\Exceptions\Exception;
use KytschBASIC\Parsers\Core\Command;

class Mail extends Command
{
	public function parse(string command, args)
	{
		if (command == "MAIL") {
			return "<?php $KBMAIL = [
				'open' => false,
				'to' => '',
				'from' => '',
				'subject' => 'An email from kyschBASIC',
				'message' => '',
				'method' => 'sendmail',
				'type' => 'html'
			]; ?>";
		} elseif (command == "MAILFROM") {
			return "<?php $KBMAIL['from'] = " .
				this->clean(
					args,
					this->isVariable(args)					
				) .
			"; ?>";
		} elseif (command == "MAILTO") {
			return "<?php $KBMAIL['to'] = " .
				this->clean(
					args,
					this->isVariable(args)
				) .
			"; ?>";
		} elseif (command == "MAILSUBJECT") {
			return "<?php $KBMAIL['subject'] = " .
				this->clean(
					args,
					this->isVariable(args)
				) .
			"; ?>";
		}  elseif (command == "MAILBODY") {
			return "<?php $KBMAIL['open'] = true; ob_start(); ?>";
		} elseif (command == "END MAILBODY") {
			return "<?php $KBMAIL['message'] = ob_get_contents(); ob_end_clean(); $KBMAIL['open'] = false;?>";
		} elseif (command == "END MAIL") {
			return "<?php (new KytschBASIC\\Parsers\\Core\\Communication\\Mail())->send($KBMAIL); ?>";
		}

		return null;
	}

	/**
	 * Send the mail using the built up options.
	 */
	 public function send(mail_options)
	 {
		if (empty(mail_options)) {
			throw new Exception("Invalid MAIL");
		}

		if (mail_options["open"]) {
			let mail_options["message"] = ob_get_contents();
			ob_end_clean();
		}

		if (empty(mail_options["to"])) {
			throw new Exception("Invalid MAIL, missing MAILTO");
		}

		var additional_headers = [
			"MIME-Version": "1.0",
			"Content-Type": "text/html; charset=UTF-8"
		];

		if (!empty(mail_options["from"])) {
			let additional_headers["from"] = mail_options["from"];
		}
		
		if (!mail(
			mail_options["to"],
			mail_options["subject"],
			mail_options["message"],
			additional_headers
		)) {
			var err, msg;

			let msg = "Failed to send the mail";

			let err = error_get_last();
			if (isset(err["message"])) {
				let msg .= ", " . err["message"];
			}
			
			throw new Exception(msg);
		}
	 }
	
}