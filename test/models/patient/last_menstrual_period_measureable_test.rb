require 'test_helper'
require_relative '../patient_test'

class PatientTest::LastMenstrualPeriodMeasureable < PatientTest
  describe 'last menstrual period calculation concern' do
    before do
      @user = create :user
      @patient = create :patient, created_by: @user,
                                  initial_call_date: 2.days.ago,
                                  last_menstrual_period_weeks: 9,
                                  last_menstrual_period_days: 2,
                                  appointment_date: 2.days.from_now
    end

    describe 'last_menstrual_period_display' do
      it 'should return nil if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.last_menstrual_period_display
      end

      it 'should return LMP in weeks and days' do
        assert_equal '9 weeks, 4 days',
                     @patient.last_menstrual_period_display
      end
    end

    describe 'last_menstrual_period_display_short' do
      it 'should return nil if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.last_menstrual_period_display_short
      end

      it 'should return shorter LMP in weeks and days' do
        assert_equal @patient.last_menstrual_period_display_short, '9w 4d'
      end
    end

    describe 'last_menstrual_period_at_appt' do
      it 'should return nil unless appt date is set' do
        @patient.appointment_date = nil
        assert_nil @patient.last_menstrual_period_at_appt
      end

      it 'should return a calculated LMP on date of appointment' do
        assert_equal '9 weeks, 6 days',
                     @patient.last_menstrual_period_at_appt
      end
    end

    describe 'last_menstrual_period_now' do
      it 'should return nil if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.send(:_last_menstrual_period_now)
      end

      it 'should be equivalent to LMP on date - Time.zone.today' do
        assert_equal  @patient.send(:_last_menstrual_period_now),
                      @patient.send(:_last_menstrual_period_on_date,
                                    Time.zone.today)
      end

      it 'should be LMP on date of appointment if appointment is in the past' do
        @patient.appointment_date = 1.day.ago
        assert_equal  @patient.send(:_last_menstrual_period_now),
                      @patient.send(:_last_menstrual_period_on_date, 1.day.ago.to_date)
      end
    end

    describe 'last_menstrual_period_on_date' do
      it 'should nil out if LMP weeks is not set' do
        @patient.last_menstrual_period_weeks = nil
        assert_nil @patient.send(:_last_menstrual_period_on_date,
                                 Time.zone.today)
      end

      it 'should accurately calculate LMP on a given date' do
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 67
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   5.days.from_now.to_date), 72

        @patient.initial_call_date = 4.days.ago
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                    Time.zone.today), 69

        @patient.last_menstrual_period_weeks = 10
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 76

        @patient.last_menstrual_period_days = 6
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 80
      end

      it 'should cap at 280 days' do
        @patient.last_menstrual_period_weeks = 52
        assert_equal @patient.send(:_last_menstrual_period_on_date,
                                   Time.zone.today), 280
      end
    end

    describe '_display_as_weeks' do
      it 'should return a value of weeks and days' do
        assert_equal '3 weeks, 3 days', @patient.send(:_display_as_weeks, 24)
      end
    end
  end
end
