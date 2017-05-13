# Methods pertaining to determining a patient's displayed status
module Statusable
  extend ActiveSupport::Concern

  STATUSES = {
    no_contact: 'No Contact Made',
    needs_appt: 'Needs Appointment',
    fundraising: 'Fundraising',
    pledge_sent: 'Pledge Sent',
    pledge_paid: 'Pledge Paid',
    resolved: 'Resolved Without DCAF'
  }.freeze

  def status
    return STATUSES[:resolved] if resolved_without_dcaf?
    return STATUSES[:pledge_sent] if pledge_sent?
    return STATUSES[:dropoff] if days_since_last_call > 120
    return STATUSES[:no_contact] unless contact_made?
    return STATUSES[:fundraising] if appointment_date
    STATUSES[:needs_appt]
  end

  private

  def contact_made?
    calls.each do |call|
      return true if call.status == 'Reached patient'
    end
    false
  end

  def days_since_last_call
    day = 86400
    days_since_last_call = (Time.zone.now - calls.sort_by(created_at).last).to_i / day
    days_since_last_call
  end
end
